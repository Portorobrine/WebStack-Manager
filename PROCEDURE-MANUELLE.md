# 📋 Procédure Manuelle - Gestion de Projets Traefik

## 🎯 Vue d'ensemble
Ce document décrit comment effectuer manuellement toutes les opérations du script `manage_projects.sh` pour gérer des projets web avec Traefik, Apache/PHP et MariaDB.

---

## 📁 Structure du projet
```
/home/matheo/projet-compose/
├── docker-compose.yml          # Configuration principale
├── Dockerfile.httpd            # Image Apache+PHP
├── Dockerfile.mariadb          # Image MariaDB
├── manage_projects.sh          # Script automatisé (référence)
├── projects/                   # Répertoires des sites web
│   └── {nom-projet}/          # Contenu web de chaque projet
└── data/                      # Données persistantes bases de données
    └── {nom-projet}/          # Données MySQL de chaque projet
```

---

## 🔍 1. LISTER LES PROJETS EXISTANTS

### Méthode 1 : Analyse du docker-compose.yml
```bash
# Rechercher les containers web des projets
grep "container_name: .*_web" docker-compose.yml

# Extraire les noms de projets
grep "container_name: .*_web" docker-compose.yml | sed 's/.*: \(.*\)_web/\1/'
```

### Méthode 2 : Vérification des répertoires
```bash
# Lister les projets par leurs répertoires
ls -1 projects/
ls -1 data/
```

### Méthode 3 : Containers Docker actifs
```bash
# Voir les containers en cours d'exécution
docker ps --format "table {{.Names}}\t{{.Status}}" | grep "_web\|_db"
```

---

## ➕ 2. AJOUTER UN NOUVEAU PROJET

### Étape 1 : Validation du nom
- ✅ **Nom requis** : Ne pas laisser vide
- ✅ **Caractères autorisés** : lettres, chiffres, tirets
- ✅ **Conversion** : Convertir en minuscules
- ❌ **Éviter** : espaces, caractères spéciaux

```bash
# Exemple de validation
nom_projet="mon-nouveau-projet"
echo "$nom_projet" | tr '[:upper:]' '[:lower:]'
```

### Étape 2 : Vérifier l'existence
```bash
# Vérifier si le projet existe déjà
grep -q "container_name: ${nom_projet}_web" docker-compose.yml
if [ $? -eq 0 ]; then
    echo "❌ Le projet '$nom_projet' existe déjà"
    exit 1
fi
```

### Étape 3 : Créer les répertoires
```bash
# Créer le répertoire du projet web
mkdir -p "projects/$nom_projet"

# Créer le répertoire des données
mkdir -p "data/$nom_projet"
```

### Étape 4 : Créer le fichier index.html
```bash
# Créer une page d'accueil basique
cat > "projects/$nom_projet/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>$nom_projet</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>Projet $nom_projet</h1>
    <p>URL: <a href="http://localhost/$nom_projet/">http://localhost/$nom_projet/</a></p>
    <p>Créé le: $(date)</p>
</body>
</html>
EOF
```

### Étape 5 : Modifier docker-compose.yml
Ouvrir `docker-compose.yml` dans un éditeur et **ajouter avant la section `networks:`** :

```yaml
  {nom_projet}_web:
    build:
      context: .
      dockerfile: Dockerfile.httpd
    container_name: {nom_projet}_web
    volumes: ["./projects/{nom_projet}:/var/www/html"]
    networks: [traefik, {nom_projet}_net]
    labels:
      - traefik.enable=true
      - traefik.http.routers.{nom_projet}.rule=Host(`localhost`) && PathPrefix(`/{nom_projet}`)
      - traefik.http.routers.{nom_projet}.entrypoints=web
      - traefik.http.services.{nom_projet}.loadbalancer.server.port=80
      - traefik.http.middlewares.{nom_projet}-strip.stripprefix.prefixes=/{nom_projet}
      - traefik.http.routers.{nom_projet}.middlewares={nom_projet}-strip
      - traefik.docker.network=projet-compose_traefik

  {nom_projet}_db:
    build:
      context: .
      dockerfile: Dockerfile.mariadb
    container_name: {nom_projet}_db
    environment: [MYSQL_ALLOW_EMPTY_PASSWORD=1, MYSQL_DATABASE={nom_projet}]
    volumes: ["./data/{nom_projet}:/var/lib/mysql"]
    networks: [{nom_projet}_net]

```

### Étape 6 : Ajouter le réseau
Dans la section `networks:`, ajouter :
```yaml
networks:
  traefik:
  {nom_projet}_net:
  # ... autres réseaux existants
```

### Étape 7 : Déployer les containers
```bash
# Construire et démarrer les nouveaux containers
docker compose up -d --build

# Vérifier que tout fonctionne
docker compose ps
```

### Étape 8 : Tester l'accès
```bash
# Tester l'accès web
curl -s http://localhost/{nom_projet}/ | head -3

# Ou ouvrir dans un navigateur
xdg-open http://localhost/{nom_projet}/
```

---

## 🗑️ 3. SUPPRIMER UN PROJET EXISTANT

### ⚠️ ATTENTION : Suppression définitive !
Cette opération supprime **définitivement** :
- Les containers web et base de données
- Le répertoire du projet et tous ses fichiers
- Les données de la base de données
- Les configurations Docker Compose

### Étape 1 : Confirmation
```bash
read -p "⚠️  Supprimer le projet '$nom_projet' ? (o/N) " confirm
if [[ ! $confirm =~ ^[Oo]$ ]]; then
    echo "Opération annulée"
    exit 0
fi
```

### Étape 2 : Arrêter les containers
```bash
# Arrêter les containers du projet
docker compose stop "${nom_projet}_web" "${nom_projet}_db"

# Supprimer les containers
docker compose rm -f "${nom_projet}_web" "${nom_projet}_db"
```

### Étape 3 : Modifier docker-compose.yml
**Supprimer manuellement** dans `docker-compose.yml` :

1. **Section du service web** :
   ```yaml
   {nom_projet}_web:
     build:
       context: .
       dockerfile: Dockerfile.httpd
     container_name: {nom_projet}_web
     volumes: ["./projects/{nom_projet}:/var/www/html"]
     networks: [traefik, {nom_projet}_net]
     labels:
       - traefik.enable=true
       - traefik.http.routers.{nom_projet}.rule=Host(`localhost`) && PathPrefix(`/{nom_projet}`)
       - traefik.http.routers.{nom_projet}.entrypoints=web
       - traefik.http.services.{nom_projet}.loadbalancer.server.port=80
       - traefik.http.middlewares.{nom_projet}-strip.stripprefix.prefixes=/{nom_projet}
       - traefik.http.routers.{nom_projet}.middlewares={nom_projet}-strip
       - traefik.docker.network=projet-compose_traefik
   ```

2. **Section du service base de données** :
   ```yaml
   {nom_projet}_db:
     build:
       context: .
       dockerfile: Dockerfile.mariadb
     container_name: {nom_projet}_db
     environment: [MYSQL_ALLOW_EMPTY_PASSWORD=1, MYSQL_DATABASE={nom_projet}]
     volumes: ["./data/{nom_projet}:/var/lib/mysql"]
     networks: [{nom_projet}_net]
   ```

3. **Réseau du projet** dans la section `networks:` :
   ```yaml
   {nom_projet}_net:
   ```

### ⚠️ IMPORTANT : Préserver le réseau Traefik
**NE JAMAIS SUPPRIMER** ces lignes :
```yaml
networks:
  traefik:    # ← OBLIGATOIRE, ne pas supprimer !
```

### Étape 4 : Supprimer les répertoires
```bash
# Supprimer le répertoire du projet web
rm -rf "projects/$nom_projet"

# Supprimer le répertoire des données (DÉFINITIF !)
rm -rf "data/$nom_projet"
```

### Étape 5 : Redémarrer la stack
```bash
# Relancer la stack sans les containers supprimés
docker compose up -d --remove-orphans
```

---

## 🔧 4. OPÉRATIONS DE MAINTENANCE

### Redémarrer tous les services
```bash
docker compose restart
```

### Voir les logs
```bash
# Logs de Traefik
docker compose logs traefik

# Logs d'un projet spécifique
docker compose logs {nom_projet}_web {nom_projet}_db

# Suivre les logs en temps réel
docker compose logs -f traefik
```

### Vérifier l'état des services
```bash
# État des containers
docker compose ps

# Utilisation des ressources
docker stats

# Réseaux Docker
docker network ls | grep projet-compose
```

### Sauvegarder les données
```bash
# Sauvegarder un projet spécifique
tar -czf backup_${nom_projet}_$(date +%Y%m%d).tar.gz \
    projects/${nom_projet}/ \
    data/${nom_projet}/

# Sauvegarder tous les projets
tar -czf backup_all_projects_$(date +%Y%m%d).tar.gz \
    projects/ data/ docker-compose.yml
```

---

## 🚨 5. RÉSOLUTION DE PROBLÈMES

### Erreur "mapping key already defined"
```bash
# Vérifier la syntaxe YAML
docker compose config

# Identifier les doublons
grep -n ":" docker-compose.yml | sort | uniq -d
```

### Problème de réseau Docker
```bash
# Lister les réseaux
docker network ls

# Nettoyer les réseaux inutilisés
docker network prune

# Redémarrer Docker (si nécessaire)
sudo systemctl restart docker
```

### Container qui ne démarre pas
```bash
# Voir les logs d'erreur
docker compose logs {nom_projet}_web

# Reconstruire l'image
docker compose build {nom_projet}_web

# Démarrer en mode debug
docker compose up {nom_projet}_web
```

### Problème d'accès web
```bash
# Vérifier que Traefik fonctionne
curl -s http://localhost:8080/api/overview

# Vérifier la configuration du routeur
curl -s http://localhost:8080/api/http/routers

# Tester l'accès direct au container
docker exec -it {nom_projet}_web curl localhost
```

---

## 📚 6. RÉFÉRENCE RAPIDE

### Commandes essentielles
```bash
# Lister les projets
grep "container_name: .*_web" docker-compose.yml | sed 's/.*: \(.*\)_web/\1/'

# État global
docker compose ps

# Logs en temps réel
docker compose logs -f

# Reconstruction complète
docker compose down && docker compose up -d --build

# Nettoyage Docker
docker system prune
```

### URLs importantes
- **Interface Traefik** : http://localhost:8080/
- **Projet example** : http://localhost/example/
- **API Traefik** : http://localhost:8080/api/

### Structure minimale docker-compose.yml
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

---

## ✅ Checklist de validation

### Après ajout d'un projet :
- [ ] Répertoires `projects/{nom}` et `data/{nom}` créés
- [ ] Fichier `index.html` présent
- [ ] Configuration ajoutée dans `docker-compose.yml`
- [ ] Réseau `{nom}_net` ajouté
- [ ] Containers démarrés : `docker compose ps`
- [ ] Accès web fonctionne : `curl http://localhost/{nom}/`

### Après suppression d'un projet :
- [ ] Containers arrêtés et supprimés
- [ ] Configuration retirée de `docker-compose.yml`
- [ ] Réseau `traefik` toujours présent
- [ ] Répertoires `projects/{nom}` et `data/{nom}` supprimés
- [ ] Stack redémarrée : `docker compose up -d`

---

📝 **Note** : Cette procédure manuelle reproduit exactement le comportement du script `manage_projects.sh`. Pour un usage fréquent, le script automatisé est recommandé.
