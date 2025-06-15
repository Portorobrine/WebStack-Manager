#!/bin/bash
# Script d'automatisation du déploiement d'un projet web (httpd + mariadb)
# Usage : ./deploy.sh nom_projet port_web

set -e

if [ $# -ne 2 ]; then
  echo "Usage : $0 nom_projet port_web"
  exit 1
fi

PROJET=$1
PORT=$2


# demander l'utilisateur pour confirmer la suppression des conteneurs et volumes existants
read -p "Le projet \"${PROJET}\" est déjà existant. Voulez-vous supprimer les conteneurs et volumes existants pour le projet ${PROJET} ? (o/n) " CONFIRM
if [[ $CONFIRM =~ ^[Oo]$ ]]; then
  docker rm -f ${PROJET}_web ${PROJET}_db || true
  docker volume rm ${PROJET}_www || true
  docker network rm ${PROJET}_net || true
  echo "Conteneurs et volumes supprimés."
else
  echo "Aucune suppression effectuée. Veuillez vérifier les conteneurs et volumes existants."
  exit 0
fi

# Création d'un réseau dédié
NETWORK=${PROJET}_net
docker network create $NETWORK || true

# Création du volume partagé
VOLUME=${PROJET}_www
docker volume create $VOLUME || true

# Démarrage de la base de données
DB_CONTAINER=${PROJET}_db
docker run -d --name $DB_CONTAINER --network $NETWORK -e MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=1 mariadb:latest

# Démarrage du serveur web
WEB_CONTAINER=${PROJET}_web
docker run -d --name $WEB_CONTAINER --network $NETWORK -p $PORT:80 -v $VOLUME:/var/www/html httpd:latest

echo "Projet $PROJET déployé sur le port $PORT. Volume partagé : $VOLUME"
