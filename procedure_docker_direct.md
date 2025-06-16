# Procédure Docker Direct - Gestion de Projets Web

## 🚀 Ajouter un projet

### 1. Démarrer Traefik (si pas déjà fait)
```bash
# Créer le réseau
docker network create traefik

# Démarrer Traefik
docker run -d \
    --name traefik \
    --network traefik \
    -p 80:80 -p 8080:8080 \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    traefik:v3.0 \
    --api.insecure=true \
    --providers.docker=true \
    --providers.docker.exposedbydefault=false \
    --entrypoints.web.address=:80
```

### 2. Créer le projet
```bash
PROJECT_NAME="ipssi"

# Créer les dossiers
mkdir -p projects/$PROJECT_NAME data/$PROJECT_NAME

# Page d'accueil
echo "<h1>$PROJECT_NAME</h1>" > projects/$PROJECT_NAME/index.html

# Réseau du projet
docker network create ${PROJECT_NAME}_net
```

### 3. Base de données
```bash
# Construire l'image
docker build -f Dockerfile.mariadb -t webstack-manager-${PROJECT_NAME}_db .

# Démarrer la DB
docker run -d \
    --name ${PROJECT_NAME}_db \
    --network ${PROJECT_NAME}_net \
    -e MARIADB_ROOT_PASSWORD=rootpassword \
    -e MARIADB_DATABASE=$PROJECT_NAME \
    -e MARIADB_USER=${PROJECT_NAME}user \
    -e MARIADB_PASSWORD=${PROJECT_NAME}password \
    -v $(pwd)/data/$PROJECT_NAME:/var/lib/mysql \
    webstack-manager-${PROJECT_NAME}_db
```

### 4. Serveur web
```bash
# Construire l'image
docker build -f Dockerfile.httpd -t webstack-manager-${PROJECT_NAME}_web .

# Démarrer le web
docker run -d \
    --name ${PROJECT_NAME}_web \
    --network traefik \
    -v $(pwd)/projects/$PROJECT_NAME:/var/www/html \
    --label "traefik.enable=true" \
    --label "traefik.http.routers.${PROJECT_NAME}.rule=Host(\`localhost\`) && PathPrefix(\`/${PROJECT_NAME}\`)" \
    --label "traefik.http.routers.${PROJECT_NAME}.entrypoints=web" \
    --label "traefik.http.services.${PROJECT_NAME}.loadbalancer.server.port=80" \
    --label "traefik.http.middlewares.${PROJECT_NAME}-strip.stripprefix.prefixes=/${PROJECT_NAME}" \
    --label "traefik.http.routers.${PROJECT_NAME}.middlewares=${PROJECT_NAME}-strip" \
    webstack-manager-${PROJECT_NAME}_web

# Connecter web à la DB
docker network connect ${PROJECT_NAME}_net ${PROJECT_NAME}_web
```

**✅ Accès : http://localhost/ipssi/**

---

## 🗑️ Supprimer un projet

```bash
PROJECT_NAME="ipssi"

# Arrêter et supprimer
docker stop ${PROJECT_NAME}_web ${PROJECT_NAME}_db
docker rm ${PROJECT_NAME}_web ${PROJECT_NAME}_db
docker network rm ${PROJECT_NAME}_net
docker rmi webstack-manager-${PROJECT_NAME}_web webstack-manager-${PROJECT_NAME}_db

# Nettoyer les fichiers
rm -rf projects/$PROJECT_NAME data/$PROJECT_NAME
```