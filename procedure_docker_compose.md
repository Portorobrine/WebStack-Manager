# Procédure Docker Compose - Gestion de Projets Web

## 📋 Vue d'ensemble

Cette stack utilise **Traefik** comme reverse proxy pour gérer automatiquement le routage des projets web. Traefik permet d'accéder à chaque projet via une URL dédiée sans conflit de ports.

## 🌐 Traefik - Reverse Proxy

### Configuration
- **Port web** : 80 (accès aux projets)
- **Dashboard** : http://localhost:8080
- **Réseau** : `traefik` (réseau partagé)

### Fonctionnalités
- **Routage automatique** : Chaque projet est accessible via `localhost/nom-projet`
- **Discovery Docker** : Détection automatique des nouveaux containers
- **Load balancing** : Répartition de charge intégrée
- **Dashboard web** : Interface de monitoring

### Accès aux projets
Tous les projets sont accessibles via :
```
http://localhost/nom-du-projet/
```

### Dashboard Traefik
Surveillez vos services en temps réel :
```
http://localhost:8080
```

---

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

---

## ⚙️ Gestion de Traefik

### Démarrer/Redémarrer Traefik
```bash
# Démarrer tous les services (y compris Traefik)
docker compose up -d

# Redémarrer uniquement Traefik
docker compose restart traefik
```

### Vérifier l'état de Traefik
```bash
# Status des containers
docker compose ps

# Logs de Traefik
docker compose logs traefik

# Logs en temps réel
docker compose logs -f traefik
```

### Configuration des labels Traefik pour un nouveau projet
Pour chaque nouveau projet, utilisez ces labels dans votre `docker-compose.yml` :

```yaml
labels:
  - traefik.enable=true
  - traefik.http.routers.PROJECT_NAME.rule=Host(`localhost`) && PathPrefix(`/PROJECT_NAME`)
  - traefik.http.routers.PROJECT_NAME.entrypoints=web
  - traefik.http.services.PROJECT_NAME.loadbalancer.server.port=80
  - traefik.http.middlewares.PROJECT_NAME-strip.stripprefix.prefixes=/PROJECT_NAME
  - traefik.http.routers.PROJECT_NAME.middlewares=PROJECT_NAME-strip
  - traefik.docker.network=webstack-manager_traefik
```

### Réseau Traefik
Chaque projet web doit être connecté au réseau `traefik` :
```yaml
networks: [traefik, project_specific_net]
```

### Troubleshooting
- **Service non accessible** : Vérifiez le dashboard Traefik (http://localhost:8080)
- **Erreur de routage** : Vérifiez les labels Traefik du container
- **Conflit de noms** : Utilisez des noms uniques pour les routers et services