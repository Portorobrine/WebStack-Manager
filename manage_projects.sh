#!/bin/bash
set -e

COMPOSE_FILE="docker-compose.yml"
PROJECTS_DIR="projects"
DATA_DIR="data"

init() {
  [ -f "$COMPOSE_FILE" ] && grep -q "traefik:" "$COMPOSE_FILE" && return
  cat > "$COMPOSE_FILE" << 'EOF'
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
EOF
}

add() {
  local name="$1"
  
  [ -z "$name" ] && { echo "Usage: $0 add [nom]"; echo "Exemple: $0 add mon-projet"; exit 1; }
  
  # Vérifier si le projet existe déjà
  if grep -q "${name}_web:" "$COMPOSE_FILE" 2>/dev/null; then
    echo "Le projet '$name' existe déjà"
    return 1
  fi
  
  init

  echo "Création du projet '$name'..."
  mkdir -p "$PROJECTS_DIR/$name"
  echo "<!DOCTYPE html><html><head><title>$name</title></head><body><h1>Projet $name</h1></body></html>" > "$PROJECTS_DIR/$name/index.html"
  
  mkdir -p "$DATA_DIR/$name"
  
  awk -v name="$name" '
  /^networks:/ {
    print ""
    print "  " name "_web:"
    print "    build:"
    print "      context: ."
    print "      dockerfile: Dockerfile.httpd"
    print "    container_name: " name "_web"
    print "    volumes: [\"./projects/" name ":/var/www/html\"]"
    print "    networks: [traefik, " name "_net]"
    print "    labels:"
    print "      - traefik.enable=true"
    print "      - traefik.http.routers." name ".rule=Host(`localhost`) && PathPrefix(`/" name "`)"
    print "      - traefik.http.routers." name ".entrypoints=web"
    print "      - traefik.http.services." name ".loadbalancer.server.port=80"
    print "      - traefik.http.middlewares." name "-strip.stripprefix.prefixes=/" name
    print "      - traefik.http.routers." name ".middlewares=" name "-strip"
    print "      - traefik.docker.network=webstack-manager_traefik"
    print ""
    print "  " name "_db:"
    print "    build:"
    print "      context: ."
    print "      dockerfile: Dockerfile.mariadb"
    print "    container_name: " name "_db"
    print "    environment: [MYSQL_ALLOW_EMPTY_PASSWORD=1, MYSQL_DATABASE=" name "]"
    print "    volumes: [\"./data/" name ":/var/lib/mysql\"]"
    print "    networks: [" name "_net]"
    print ""
  }
  /^networks:/ { print $0; getline; print; print "  " name "_net:"; next }
  { print }
  ' "$COMPOSE_FILE" > /tmp/compose && mv /tmp/compose "$COMPOSE_FILE"
  echo "'$name' créé - http://localhost/$name/"
  docker compose up -d --remove-orphans
}

remove() {
  local name="$1"
  [ -z "$name" ] && { echo "Nom du projet requis"; exit 1; }
  
  # Vérifier si le projet existe
  if ! grep -q "${name}_web:" "$COMPOSE_FILE" 2>/dev/null; then
    echo "Le projet '$name' n'existe pas"
    return 0
  fi
  
  echo "Suppression '$name'..."
  docker compose stop "${name}_web" "${name}_db"
  docker compose rm -f "${name}_web" "${name}_db"
  
  awk -v name="$name" '
  BEGIN { skip=0 }
  # Début dun service du projet à supprimer
  $0 ~ "^  " name "_(web|db):" { skip=1; next }
  # Fin du service : nouvelle ligne de service ou section networks
  skip && ($0 ~ /^  [a-zA-Z][^:]*:/ || $0 ~ /^[a-zA-Z]/) { skip=0 }
  # Ignorer les lignes du service en cours de suppression
  skip { next }
  # Supprimer le réseau spécifique au projet
  $0 == "  " name "_net:" { next }
  # Garder toutes les autres lignes
  { print }
  ' "$COMPOSE_FILE" > /tmp/compose && mv /tmp/compose "$COMPOSE_FILE"
  
  rm -rf "$PROJECTS_DIR/$name"
  rm -rf "$DATA_DIR/$name"
  
  echo "'$name' supprimé"
  docker compose up -d --remove-orphans
}

case "$1" in
  add) 
    if [ -z "$2" ]; then
      echo "Usage: $0 add [nom-projet]"
      exit 1
    fi
    add "$2"
    ;;
  remove) 
    if [ -z "$2" ]; then
      echo "Usage: $0 remove [nom-projet]" 
      exit 1
    fi
    remove "$2"
    ;;
  *) 
    echo "Usage: $0 {add|remove} [nom]"
    exit 1
    ;;
esac
