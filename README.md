# Gestionnaire de Projets Web avec Traefik

Script Bash simple pour créer et gérer des projets web avec Traefik comme reverse proxy.

## Prérequis

- Docker et Docker Compose installés
- Port 80 et 8080 libres

## Utilisation

```bash
# Créer un projet
./manage_projects.sh add mon-projet

# Supprimer un projet
./manage_projects.sh remove mon-projet
```

## Accès

- **Projet** : http://localhost/mon-projet/
- **Traefik Dashboard** : http://localhost:8080/

## Structure automatique

Chaque projet contient :
- Un serveur web Apache (httpd)
- Une base de données MariaDB
- Un réseau isolé
- Un volume pour les données

## Fichiers

- `manage_projects.sh` - Script principal
- `docker-compose.yml` - Configuration automatique
- `projects/` - Dossiers des projets
- 'data/' - Dossier pour les données persistantes
