# 📚 Tutoriel : Utilisation du script manage_projects.sh

## 🎯 Objectif
Ce tutoriel vous guide pas à pas pour maîtriser le script `manage_projects.sh` et son système de gestion des sites nginx avec architecture sites-available/sites-enabled.

---

## 🚀 Démarrage rapide (5 minutes)

### Étape 1 : Préparation
```bash
# Rendre le script exécutable
chmod +x manage_projects.sh

# Vérifier que Docker fonctionne
docker --version
docker compose --version
```

### Étape 2 : Premier projet
```bash
# Créer votre premier projet
./manage_projects.sh add monpremiersite

# 🎉 Le script fait automatiquement :
# - Trouve un port libre (ex: 8080)
# - Crée le dossier projects/monpremiersite/
# - Génère un index.html par défaut
# - Configure les conteneurs web + base de données
# - Crée le site nginx
# - Active le site
# - Démarre l'infrastructure
```

### Étape 3 : Vérification
```bash
# Voir l'état des projets
./manage_projects.sh list

# Voir l'état des sites nginx
./manage_projects.sh site-list

# Tester l'accès
curl http://localhost/
curl http://localhost/monpremiersite/
```

---

## 📖 Tutoriel détaillé

### 🏗️ Section 1 : Gestion des projets

#### 1.1 Créer des projets
```bash
# Projet avec port automatique (recommandé)
./manage_projects.sh add boutique
# ➜ Port assigné automatiquement (ex: 8080)

# Projet avec port spécifique
./manage_projects.sh add blog 8085
# ➜ Utilise le port 8085

# Sans déploiement automatique
./manage_projects.sh --no-deploy add test
# ➜ Crée la configuration mais ne démarre pas les conteneurs
```

#### 1.2 Lister les projets
```bash
./manage_projects.sh list
```
**Sortie exemple :**
```
Projets existants dans docker-compose.yml:
  - boutique (port: 8080)
  - blog (port: 8085)
  - test (port: 8081)
```

#### 1.3 Modifier un projet
```bash
# Changer le port d'un projet
./manage_projects.sh modify boutique 8090
# ➜ Le port de "boutique" passe de 8080 à 8090
```

#### 1.4 Supprimer un projet
```bash
./manage_projects.sh remove test
# ➜ Demande confirmation pour supprimer le dossier
```

### 🌐 Section 2 : Gestion des sites nginx

#### 2.1 Voir l'état des sites
```bash
./manage_projects.sh site-list
```
**Sortie exemple :**
```
Sites disponibles:
  ✓ default (activé)
  ✓ boutique (activé)
  ✗ blog (désactivé)
```

#### 2.2 Activer/Désactiver un site
```bash
# Désactiver un site (maintenance)
./manage_projects.sh site-disable boutique
# ➜ Le site n'est plus accessible via nginx, mais le conteneur tourne

# Réactiver le site
./manage_projects.sh site-enable boutique
# ➜ Le site redevient accessible immédiatement
```

#### 2.3 Créer un site pour un projet existant
```bash
# Si vous avez un projet sans site nginx
./manage_projects.sh site-create ancien-projet
# ➜ Crée la configuration nginx pour ce projet
```

#### 2.4 Supprimer un site
```bash
./manage_projects.sh site-remove blog
# ➜ Supprime la configuration nginx (pas le conteneur)
```

---

## 🎪 Scénarios pratiques

### Scénario 1 : Créer une infrastructure complète
```bash
# 1. Créer plusieurs projets d'un coup
./manage_projects.sh add entreprise
./manage_projects.sh add blog 8085
./manage_projects.sh add ecommerce

# 2. Vérifier la création
./manage_projects.sh list
./manage_projects.sh site-list

# 3. Accéder aux sites
echo "Page d'accueil : http://localhost/"
echo "Entreprise : http://localhost/entreprise/"
echo "Blog : http://localhost/blog/"
echo "E-commerce : http://localhost/ecommerce/"
```

### Scénario 2 : Maintenance d'un site
```bash
# 1. Site en maintenance
./manage_projects.sh site-disable ecommerce
echo "Site e-commerce hors ligne pour maintenance"

# 2. Le conteneur continue de tourner
docker ps | grep ecommerce
# ➜ Le conteneur est toujours actif

# 3. Remise en ligne
./manage_projects.sh site-enable ecommerce
echo "Site e-commerce de nouveau accessible"
```

### Scénario 3 : Gestion des conflits de ports
```bash
# 1. Tentative d'utilisation d'un port occupé
./manage_projects.sh add nouveau 8080
# ➜ Erreur : port déjà utilisé par "entreprise"

# 2. Le script propose une solution
# ➜ "Voulez utilise le port suivant disponible: 8082 ? (o/n)"

# 3. Ou changer manuellement
./manage_projects.sh modify entreprise 8090
./manage_projects.sh add nouveau 8080
```

### Scénario 4 : Développement avec hot-reload
```bash
# 1. Créer un projet de développement
./manage_projects.sh add dev-site

# 2. Modifier le contenu
echo "<h1>Version 2.0</h1>" > projects/dev-site/index.html

# 3. Voir les changements immédiatement
curl http://localhost/dev-site/
# ➜ Les modifications sont visibles instantanément
```

---

## 🔧 Commandes avancées

### Options globales
```bash
# Créer sans déployer automatiquement
./manage_projects.sh --no-deploy add test-site

# Déployer manuellement après
docker compose up -d
```

### Gestion fine des sites
```bash
# Voir les fichiers de configuration
ls -la nginx_config/sites-available/
ls -la nginx_config/sites-enabled/

# Éditer manuellement un site (avancé)
nano nginx_config/sites-available/monsite

# Recharger nginx après modification manuelle
docker exec reverse_proxy nginx -s reload
```

---

## 🌍 Accès aux sites

### Méthodes d'accès
Chaque projet est accessible via plusieurs méthodes :

```bash
# 1. Via le reverse proxy (recommandé)
curl http://localhost/monsite/

# 2. Via port direct
curl http://localhost:8080/

# 3. Via sous-domaine (nécessite configuration DNS)
# Ajouter dans /etc/hosts : 127.0.0.1 monsite.localhost
curl http://monsite.localhost/
```

### Page d'accueil
```bash
# Accéder à la page d'accueil
curl http://localhost/
# ➜ Liste tous les projets avec leurs statuts

# Page de statut détaillée
curl http://localhost/status
# ➜ Statut technique des sites
```

---

## 🛠️ Dépannage courant

### Problème : Port en conflit
```bash
# Symptôme
./manage_projects.sh add site1 8080
# "Erreur: Le port 8080 est déjà utilisé par le projet 'autre-site'"

# Solution 1 : Laisser le script choisir
./manage_projects.sh add site1
# ➜ Port automatique

# Solution 2 : Changer le port du projet existant
./manage_projects.sh modify autre-site 8090
./manage_projects.sh add site1 8080
```

### Problème : Site inaccessible
```bash
# Vérifier l'état du site
./manage_projects.sh site-list

# Si désactivé, l'activer
./manage_projects.sh site-enable monsite

# Vérifier les conteneurs
docker ps

# Redémarrer si nécessaire
docker compose restart reverse_proxy
```

### Problème : Configuration nginx cassée
```bash
# Tester la configuration
docker exec reverse_proxy nginx -t

# Voir les logs
docker logs reverse_proxy

# Reconstruire le reverse proxy
docker compose build reverse_proxy
docker compose up -d reverse_proxy
```

---

## 📁 Structure des fichiers

### Après création de projets
```
projet-compose/
├── projects/                    # Contenu des sites
│   ├── boutique/
│   │   └── index.html          # Page web
│   ├── blog/
│   │   └── index.html
│   └── entreprise/
│       └── index.html
├── nginx_config/                # Configuration nginx
│   ├── nginx.conf              # Config principale
│   ├── sites-available/        # Sites configurés
│   │   ├── default            # Page d'accueil
│   │   ├── boutique           # Config nginx boutique
│   │   ├── blog               # Config nginx blog
│   │   └── entreprise         # Config nginx entreprise
│   └── sites-enabled/          # Sites actifs (liens symboliques)
│       ├── default -> ../sites-available/default
│       ├── boutique -> ../sites-available/boutique
│       └── entreprise -> ../sites-available/entreprise
├── docker-compose.yml          # Services Docker
├── Dockerfile.nginx           # Image nginx personnalisée
├── Dockerfile.httpd           # Image Apache personnalisée
└── manage_projects.sh         # Script principal
```

---

## 🎓 Cas d'usage professionnels

### 1. Agence web avec plusieurs clients
```bash
# Créer un projet par client
./manage_projects.sh add client-restaurant
./manage_projects.sh add client-garage  
./manage_projects.sh add client-coiffeur

# Page d'accueil montre tous les projets
curl http://localhost/
```

### 2. Développement avec environnements multiples
```bash
# Environnements de développement
./manage_projects.sh add myapp-dev
./manage_projects.sh add myapp-staging
./manage_projects.sh add myapp-demo

# Test rapide de désactivation
./manage_projects.sh site-disable myapp-dev
```

### 3. Formation/démonstrations
```bash
# Créer rapidement des environnements de démo
./manage_projects.sh add demo1
./manage_projects.sh add demo2
./manage_projects.sh add demo3

# Désactiver les demos non utilisées
./manage_projects.sh site-disable demo2
./manage_projects.sh site-disable demo3
```

---

## ✅ Checklist de validation

Après avoir suivi ce tutoriel, vous devriez pouvoir :

- [ ] Créer un nouveau projet avec `add`
- [ ] Lister les projets avec `list`
- [ ] Voir l'état des sites avec `site-list`
- [ ] Activer/désactiver un site avec `site-enable`/`site-disable`
- [ ] Accéder à la page d'accueil sur `http://localhost/`
- [ ] Accéder à un projet via `http://localhost/nom-projet/`
- [ ] Modifier le port d'un projet avec `modify`
- [ ] Supprimer un projet avec `remove`
- [ ] Résoudre les conflits de ports
- [ ] Diagnostiquer les problèmes avec les logs

---

## 🚀 Pour aller plus loin

### Personnalisation avancée
- Modifier les templates HTML dans le script
- Ajouter des configurations nginx personnalisées
- Intégrer SSL/TLS avec Let's Encrypt
- Ajouter l'authentification par site

### Monitoring
- Utiliser `docker stats` pour surveiller les ressources
- Configurer des alertes sur les sites down
- Ajouter des logs centralisés

**🎉 Félicitations ! Vous maîtrisez maintenant le système de gestion des projets avec nginx !**
