#!/bin/bash
set -e

PROJECTS_DIR="projects"
DATA_DIR="data"


init_traefik() {
    if docker ps --format "{{.Names}}" | grep -q "^traefik$"; then
        return 0
    fi
    
    echo "Démarrage de Traefik..."
    
    if ! docker network ls --format "{{.Name}}" | grep -q "^traefik$"; then
        echo "Création du réseau traefik..."
        docker network create traefik
    fi
    
    docker run -d \
        --name traefik \
        --network traefik \
        -p 80:80 \
        -p 8080:8080 \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        --label "traefik.enable=true" \
        traefik:v3.0 \
        --api.insecure=true \
        --providers.docker=true \
        --providers.docker.exposedbydefault=false \
        --entrypoints.web.address=:80
}

add() {
    local name="$1"
    
    [ -z "$name" ] && { echo "Nom du projet requis"; exit 1; }
    
    # Vérifier si le projet existe déjà
    if docker ps -a --format "{{.Names}}" | grep -q "^${name}_web$"; then
        echo "Le projet '$name' existe déjà"
        return 0
    fi
    
    echo "Création du projet '$name'..."
    
    init_traefik
    
    # Créer les répertoires
    mkdir -p "$PROJECTS_DIR/$name"
    mkdir -p "$DATA_DIR/$name"
    
    # Créer la page d'index
    echo "<!DOCTYPE html><html><head><title>$name</title></head><body><h1>Projet $name</h1></body></html>" > "$PROJECTS_DIR/$name/index.html"
    
    # Créer le réseau du projet
    if ! docker network ls --format "{{.Name}}" | grep -q "^${name}_net$"; then
        docker network create "${name}_net"
    fi
    
    # Construire et démarrer la base de données
    echo "Démarrage de la base de données ${name}_db..."
    docker build -f Dockerfile.mariadb -t "webstack-manager-${name}_db" .
    docker run -d \
        --name "${name}_db" \
        --network "${name}_net" \
        -e MYSQL_ALLOW_EMPTY_PASSWORD=1 \
        -e MYSQL_DATABASE="$name" \
        -v "$(pwd)/$DATA_DIR/$name:/var/lib/mysql" \
        "webstack-manager-${name}_db"
    
    # Construire et démarrer le serveur web
    echo "Démarrage du serveur web ${name}_web..."
    docker build -f Dockerfile.httpd -t "webstack-manager-${name}_web" .
    docker run -d \
        --name "${name}_web" \
        --network traefik \
        -v "$(pwd)/$PROJECTS_DIR/$name:/var/www/html" \
        --label "traefik.enable=true" \
        --label "traefik.http.routers.${name}.rule=Host(\`localhost\`) && PathPrefix(\`/${name}\`)" \
        --label "traefik.http.routers.${name}.entrypoints=web" \
        --label "traefik.http.services.${name}.loadbalancer.server.port=80" \
        --label "traefik.http.middlewares.${name}-strip.stripprefix.prefixes=/${name}" \
        --label "traefik.http.routers.${name}.middlewares=${name}-strip" \
        --label "traefik.docker.network=traefik" \
        "webstack-manager-${name}_web"
    
    # Connecter le serveur web au réseau du projet pour accéder à la DB
    docker network connect "${name}_net" "${name}_web"
    
    echo "'$name' créé - http://localhost/$name/"
}

# Fonction pour supprimer un projet
remove() {
    local name="$1"
    
    [ -z "$name" ] && { echo "Nom du projet requis"; exit 1; }
    
    # Vérifier si le projet existe
    if ! docker ps -a --format "{{.Names}}" | grep -q "^${name}_web$"; then
        echo "Le projet '$name' n'existe pas"
        return 0
    fi
    
    echo "Suppression du projet '$name'..."
    
    # Arrêter et supprimer les conteneurs
    docker stop "${name}_web" "${name}_db" 2>/dev/null || true
    docker rm "${name}_web" "${name}_db" 2>/dev/null || true
    docker network rm "${name}_net" 2>/dev/null || true
    
    # Supprimer les répertoires
    rm -rf "$PROJECTS_DIR/$name" 2>/dev/null || true
    rm -rf "$DATA_DIR/$name" 2>/dev/null || true
    
    echo "'$name' supprimé"
}

case "$1" in
    add) add "$2" ;;
    remove) remove "$2" ;;
    *) echo "Usage: $0 {add|remove} [nom]"; exit 1 ;;
esac
