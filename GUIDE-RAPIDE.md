# 🚀 Guide Rapide - Actions Manuelles

## ➕ Ajouter un projet (version courte)

```bash
# 1. Variables
nom_projet="mon-projet"

# 2. Créer les répertoires
mkdir -p "projects/$nom_projet" "data/$nom_projet"

# 3. Créer index.html
echo "<!DOCTYPE html><html><head><title>$nom_projet</title></head><body><h1>Projet $nom_projet</h1><p>URL: http://localhost/$nom_projet/</p></body></html>" > "projects/$nom_projet/index.html"

# 4. Éditer docker-compose.yml - AJOUTER avant "networks:" :
```
```yaml
  mon-projet_web:
    build:
      context: .
      dockerfile: Dockerfile.httpd
    container_name: mon-projet_web
    volumes: ["./projects/mon-projet:/var/www/html"]
    networks: [traefik, mon-projet_net]
    labels:
      - traefik.enable=true
      - traefik.http.routers.mon-projet.rule=Host(`localhost`) && PathPrefix(`/mon-projet`)
      - traefik.http.routers.mon-projet.entrypoints=web
      - traefik.http.services.mon-projet.loadbalancer.server.port=80
      - traefik.http.middlewares.mon-projet-strip.stripprefix.prefixes=/mon-projet
      - traefik.http.routers.mon-projet.middlewares=mon-projet-strip
      - traefik.docker.network=projet-compose_traefik

  mon-projet_db:
    build:
      context: .
      dockerfile: Dockerfile.mariadb
    container_name: mon-projet_db
    environment: [MYSQL_ALLOW_EMPTY_PASSWORD=1, MYSQL_DATABASE=mon-projet]
    volumes: ["./data/mon-projet:/var/lib/mysql"]
    networks: [mon-projet_net]
```

```bash
# 5. Ajouter dans la section networks:
#   mon-projet_net:

# 6. Déployer
docker compose up -d
```

---

## 🗑️ Supprimer un projet (version courte)

```bash
# 1. Variable
nom_projet="mon-projet"

# 2. Arrêter containers
docker compose stop "${nom_projet}_web" "${nom_projet}_db"
docker compose rm -f "${nom_projet}_web" "${nom_projet}_db"

# 3. Éditer docker-compose.yml - SUPPRIMER :
#   - Section complète {nom_projet}_web
#   - Section complète {nom_projet}_db  
#   - Ligne {nom_projet}_net: (dans networks)
#   ⚠️  NE PAS supprimer "traefik:" dans networks !

# 4. Supprimer répertoires
rm -rf "projects/$nom_projet" "data/$nom_projet"

# 5. Redémarrer
docker compose up -d --remove-orphans
```

---

## 📋 Commandes utiles

```bash
# Lister projets actifs
grep "container_name: .*_web" docker-compose.yml | sed 's/.*: \(.*\)_web/\1/'

# État des containers
docker compose ps

# Logs temps réel
docker compose logs -f

# Reconstruire tout
docker compose down && docker compose up -d --build

# Tester un projet
curl http://localhost/{nom-projet}/

# Vérifier Traefik
curl http://localhost:8080/api/overview
```

---

## 🔧 Dépannage express

| Problème | Solution |
|----------|----------|
| "mapping key already defined" | `docker compose config` pour vérifier YAML |
| Container ne démarre pas | `docker compose logs {nom}_web` |
| Page inaccessible | Vérifier routes Traefik sur :8080 |
| Erreur réseau Docker | `docker network prune` |
| Permissions fichiers | `sudo chown -R $USER:$USER projects/ data/` |

---

## 📁 Template docker-compose.yml

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

  # ← Ajouter les projets ICI

networks:
  traefik:
  # ← Ajouter les réseaux projets ICI
```
