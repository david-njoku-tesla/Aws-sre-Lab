# 7. Démarrage de Prometheus + Grafana en arrière-plan
docker-compose up -d

# 8. Lancement de l'exporter Python en arrière-plan (survit à la fermeture du terminal)
nohup python3 monitoring/monitor.py > monitor.log 2>&1 &

echo "Exporter lancé en arrière-plan → voir monitor.log"
echo "Accès : http://$(curl -s ifconfig.me):8000/metrics ou localhost:8000"
