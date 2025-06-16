# Procédure Docker Compose - Gestion de Projets Web

## 🚀 Ajouter un projet

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

**✅ Accès : http://localhost/ipssi/**

---

## 🗑️ Supprimer un projet

### 1. Arrêter les services
```bash
docker compose stop ipssi_web ipssi_db
docker compose rm -f ipssi_web ipssi_db
```

### 2. Supprimer du docker-compose.yml
- Supprimer les sections `ipssi_web:` et `ipssi_db:`
- Supprimer `ipssi_net:` des networks

### 3. Nettoyer les fichiers
```bash
rm -rf projects/ipssi data/ipssi
docker compose up -d --remove-orphans
```