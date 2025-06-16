# Procédure Projet-compose

## Ajouter un projet

### 0. Prérequis
- créer un fichier `docker-compose.yml` à la racine du projet avec le contenu suivant :

```yaml

services:
  traefik:
    image: traefik:v3.0
    container_name: traefik
    command: 
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
    ports: ["80:80", "8080:8080"]
    volumes: 
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
    networks: [traefik]
    labels: ["traefik.enable=true"]

networks:
  traefik:

```
- Ne pas oublier d'importer les dockerfiles dans le même dossier que le `docker-compose.yml` :
  - `Dockerfile.httpd` pour le serveur web
  - `Dockerfile.mariadb` pour la base de données
  - `docker-entrypoint.sh` dépendence pour Dockerfile.mariadb

### 1. Préparer le projet
```bash
PROJECT_NAME="ipssi"

# Créer les dossiers
mkdir -p projects/$PROJECT_NAME data/$PROJECT_NAME

# Page d'accueil
echo "<h1>$PROJECT_NAME</h1>" > projects/$PROJECT_NAME/index.html
```

### 2. Ajouter au docker-compose.yml
Ajouter avant la section `networks:` :

```yaml
  ipssi_web:
    build:
      context: .
      dockerfile: Dockerfile.httpd
    container_name: ipssi_web
    volumes: ["./projects/ipssi:/var/www/html"]
    networks: [traefik, ipssi_net]
    labels:
      - traefik.enable=true
      - traefik.http.routers.ipssi.rule=Host(`localhost`) && PathPrefix(`/ipssi`)
      - traefik.http.routers.ipssi.entrypoints=web
      - traefik.http.services.ipssi.loadbalancer.server.port=80
      - traefik.http.middlewares.ipssi-strip.stripprefix.prefixes=/ipssi
      - traefik.http.routers.ipssi.middlewares=ipssi-strip
      - traefik.docker.network=webstack-manager_traefik

  ipssi_db:
    build:
      context: .
      dockerfile: Dockerfile.mariadb
    container_name: ipssi_db
    volumes: ["./data/ipssi:/var/lib/mysql"]
    networks: [ipssi_net]
```

Ajouter dans la section `networks:` :
```yaml
  ipssi_net:
```

### 3. Démarrer
```bash
docker compose up -d
```

**Accès : http://localhost/ipssi/**

