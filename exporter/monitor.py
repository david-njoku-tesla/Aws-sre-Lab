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
