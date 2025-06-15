#!/bin/bash
# Script d'automatisation du déploiement d'un projet web (httpd + mariadb) sous LXD
# Usage : ./deploy_lxd.sh nom_projet port_web

set -e

if [ $# -ne 2 ]; then
  echo "Usage : $0 nom_projet port_web"
  exit 1
fi

PROJET=$1
PORT=$2

# Création du dossier partagé
SHARE_DIR=/srv/${PROJET}_www
mkdir -p $SHARE_DIR

# Création du conteneur web
lxc launch images:ubuntu/22.04 ${PROJET}-web
lxc config device add ${PROJET}-web webshare disk source=$SHARE_DIR path=/var/www/html
lxc exec ${PROJET}-web -- apt-get update
lxc exec ${PROJET}-web -- apt-get install -y apache2
lxc config device add ${PROJET}-web httpdport proxy listen=tcp:0.0.0.0:$PORT connect=tcp:127.0.0.1:80

# Création du conteneur db
lxc launch images:ubuntu/22.04 ${PROJET}-db
lxc exec ${PROJET}-db -- apt-get update
lxc exec ${PROJET}-db -- apt-get install -y mariadb-server

# Sécurisation de la base de données (iptables)
lxc exec ${PROJET}-db -- bash -c "iptables -F && iptables -A INPUT -p tcp --dport 3306 -s $(lxc list ${PROJET}-web -c 4 | awk '/RUNNING/ {print $2}') -j ACCEPT && iptables -A INPUT -p tcp --dport 3306 -j DROP"

echo "Projet $PROJET déployé sous LXD. Dossier partagé : $SHARE_DIR"
