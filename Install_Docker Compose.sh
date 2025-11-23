# 5. Installation de Docker Compose v2 (version standalone, car CloudShell n'a pas Compose v2 nativement)
sudo rm -f /usr/local/bin/docker-compose              # Supprime l'ancienne version si présente

curl -L "https://github.com/docker/compose/releases/download/v2.29.1/docker-compose-$(uname -s)-$(uname -m)" -o ~/docker-compose

chmod +x ~/docker-compose                              # Rend le binaire exécutable

export PATH="$HOME:$PATH"                              # Ajoute ~/ au PATH pour cette session

# 6. Vérification de la version
docker-compose --version                               # Doit afficher docker-compose version v2.29.1
