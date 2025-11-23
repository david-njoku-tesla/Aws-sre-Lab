# 1. Création de l'arborescence du lab
mkdir -p ~/aws-sre-lab/{monitoring,scripts,manifests}
cd ~/aws-sre-lab

# 2. Création du docker-compose.yml (Prometheus + Grafana)
cat > docker-compose.yml <<'EOF'
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest                 # Image officielle Prometheus
    ports: ["9090:9090"]                           # Prometheus accessible sur le port 9090
    volumes: ["./prometheus.yml:/etc/prometheus/prometheus.yml"]  # Montage du fichier de config
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest                  # Image officielle Grafana
    ports: ["3000:3000"]                           # Grafana accessible sur le port 3000
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin           # Mot de passe admin (à changer après)
    depends_on: [prometheus]                       # Grafana démarre après Prometheus
    restart: unless-stopped
EOF

# 3. Configuration minimale de Prometheus (scrappe notre exporter Python)
cat > prometheus.yml <<'EOF'
global:
  scrape_interval: 15s                            # Fréquence de collecte globale

scrape_configs:
  - job_name: 'homelab'                           # Nom du job visible dans l'UI
    static_configs:
      - targets: ['172.17.0.1:8000']              # Adresse de l'exporter Python (vue depuis les conteneurs)
EOF

# 4. Script Python qui expose les métriques CPU/RAM de la machine hôte
cat > monitoring/monitor.py <<'EOF'
#!/usr/bin/env python3
# Exporter Prometheus simple pour CPU et RAM de l'hôte (CloudShell ou autre)

from prometheus_client import start_http_server, Gauge
import psutil
import time

# Création des jauges Prometheus
cpu = Gauge('cloudshell_cpu_percent', 'Pourcentage CPU utilisé sur l\'hôte')
mem = Gauge('cloudshell_memory_percent', 'Pourcentage RAM utilisé sur l\'hôte')

# Démarrage du serveur HTTP qui expose /metrics sur le port 8000
start_http_server(8000)
print("Exporter Prometheus démarré → http://localhost:8000/metrics")

# Boucle infinie de mise à jour des métriques
while True:
    cpu.set(psutil.cpu_percent(interval=1))           # Mise à jour CPU
    mem.set(psutil.virtual_memory().percent)         # Mise à jour RAM
    time.sleep(5)                                     # Toutes les 5 secondes
EOF
chmod +x monitoring/monitor.py                        # Rend le script exécutable

# 5. Installation de Docker Compose v2 (version standalone, car CloudShell n'a pas Compose v2 nativement)
sudo rm -f /usr/local/bin/docker-compose              # Supprime l'ancienne version si présente
curl -L "https://github.com/docker/compose/releases/download/v2.29.1/docker-compose-$(uname -s)-$(uname -m)" -o ~/docker-compose
chmod +x ~/docker-compose                              # Rend le binaire exécutable
export PATH="$HOME:$PATH"                              # Ajoute ~/ au PATH pour cette session

# 6. Vérification de la version
docker-compose --version                               # Doit afficher docker-compose version v2.29.1

# 7. Démarrage de Prometheus + Grafana en arrière-plan
docker-compose up -d

# 8. Lancement de l'exporter Python en arrière-plan (survit à la fermeture du terminal)
nohup python3 monitoring/monitor.py > monitor.log 2>&1 &


echo ""
echo "Dans Grafana → Add data source → Prometheus → URL : http://prometheus:9090"
