# WebStack-Manager

## Présentation
WebStack-Manager est une solution complète pour moderniser l'infrastructure web de la société Company01. Ce projet permet de migrer facilement les services web et bases de données vers des conteneurs Docker modernes, avec un reverse proxy intelligent et une interface de gestion simplifiée.

**🆕 Nouveauté : Système de gestion automatisé des projets web avec reverse proxy intégré**

---

## Partie 1 : Infrastructure de base (Docker)

### 1. Prérequis
- Docker et Docker Compose installés sur la machine hôte

### 2. Architecture moderne
- **Images officielles** : `httpd:latest` et `mariadb:latest`
- **Organisation en dossiers** : Chaque projet dans `projects/nom_projet/`
- **Gestion automatisée** : Script intelligent pour la gestion des projets
- **Reverse proxy intelligent** : Nginx avec gestion sites-available/sites-enabled
- **Contrôle granulaire** : Activation/désactivation des sites indépendamment des conteneurs

### 3. Gestion des projets avec le script `manage_projects.sh`

#### 3.1. Commandes principales

```bash
chmod +x manage_projects.sh

# Ajouter un projet (port automatique)
./manage_projects.sh add monsite

# Ajouter un projet avec port spécifique
./manage_projects.sh add monsite 8085

# Lister tous les projets
./manage_projects.sh list

# Modifier le port d'un projet
./manage_projects.sh modify monsite 8090

# Supprimer un projet
./manage_projects.sh remove monsite

# Configurer le reverse proxy
./manage_projects.sh proxy

# Options avancées
./manage_projects.sh --no-deploy add site3  # Sans déploiement automatique
```

#### 3.2. Gestion des sites nginx (sites-available/sites-enabled)

Le nouveau système utilise une approche similaire à Apache/nginx sur Ubuntu avec les répertoires `sites-available` et `sites-enabled` :

```bash
# Lister tous les sites et leur statut
./manage_projects.sh site-list

# Activer un site
./manage_projects.sh site-enable monsite

# Désactiver un site
./manage_projects.sh site-disable monsite

# Créer un site pour un projet existant
./manage_projects.sh site-create monsite

# Supprimer complètement un site
./manage_projects.sh site-remove monsite
```

#### 3.2. Gestion avancée des sites nginx (sites-available/sites-enabled)

**🔥 Fonctionnalité principale :** Le système utilise maintenant une approche similaire à Apache/nginx sur Ubuntu avec les répertoires `sites-available` et `sites-enabled`. Cela permet un contrôle granulaire des sites web.

```bash
# Lister tous les sites et leur statut (✓ activé / ✗ désactivé)
./manage_projects.sh site-list

# Activer un site (créer le lien symbolique)
./manage_projects.sh site-enable monsite

# Désactiver un site (supprimer le lien symbolique)
./manage_projects.sh site-disable monsite

# Créer un site pour un projet existant
./manage_projects.sh site-create monsite

# Supprimer complètement un site
./manage_projects.sh site-remove monsite
```

#### 3.3. Structure des sites nginx

```
nginx_config/
├── nginx.conf                 # Configuration nginx principale
├── sites-available/           # Tous les sites configurés
│   ├── default               # Site par défaut avec page d'accueil
│   ├── monsite               # Configuration du projet monsite
│   └── boutique              # Configuration du projet boutique
└── sites-enabled/             # Sites actifs (liens symboliques)
    ├── default -> ../sites-available/default
    ├── monsite -> ../sites-available/monsite
    └── boutique -> ../sites-available/boutique
```

**Avantages :**
- ✅ Activation/désactivation des sites sans redémarrer les conteneurs
- ✅ Page d'accueil dynamique listant tous les projets
- ✅ Accès multiple : sous-domaines (`monsite.localhost`) et sous-répertoires (`/monsite/`)
- ✅ Gestion indépendante des sites et des conteneurs

#### 3.4. Fonctionnalités du système

- **Attribution automatique des ports** (à partir de 8080)
- **Déploiement automatique** après ajout de projet
- **Création automatique de sites nginx** lors de l'ajout
- **Noms en minuscules** (conversion automatique)
- **Gestion des conflits** (ports et noms existants)
- **Création de dossiers** et fichiers HTML par défaut
- **Volumes persistants** pour les bases de données
- **Page d'accueil dynamique** avec statut des sites
- **Rechargement automatique** de nginx lors des modifications

### 4. Structure générée automatiquement

```
projet-compose/
├── projects/                  # Projets web
│   ├── site1/
│   │   └── index.html
│   ├── site2/
│   │   └── index.html
│   └── boutique/
│       └── index.html
├── nginx_config/              # Configuration nginx
│   ├── nginx.conf            # Configuration principale
│   ├── sites-available/      # Sites configurés
│   │   ├── default
│   │   ├── site1
│   │   └── boutique
│   └── sites-enabled/        # Sites actifs
│       ├── default -> ../sites-available/default
│       ├── site1 -> ../sites-available/site1
│       └── boutique -> ../sites-available/boutique
├── docker-compose.yml         # Généré automatiquement
├── Dockerfile.nginx          # Image nginx personnalisée
├── Dockerfile.httpd          # Image Apache personnalisée
└── manage_projects.sh        # Script principal ⭐
```

### 5. Accès aux services

#### 5.1. Accès direct par ports
- Site1 : `http://localhost:8080`
- Site2 : `http://localhost:8081`  
- Boutique : `http://localhost:8082`

#### 5.2. Accès via reverse proxy (automatique)
- **🏠 Page d'accueil** : `http://localhost/`
- **📊 Statut des sites** : `http://localhost/status`
- Site1 : `http://localhost/site1/` ou `http://site1.localhost/`
- Site2 : `http://localhost/site2/` ou `http://site2.localhost/`
- Boutique : `http://localhost/boutique/` ou `http://boutique.localhost/`

#### 5.3. Gestion dynamique des sites
```bash
# Désactiver temporairement un site
./manage_projects.sh site-disable boutique

# Vérifier l'état
./manage_projects.sh site-list
# Sortie: ✗ boutique (désactivé)

# Réactiver
./manage_projects.sh site-enable boutique
```

### 6. Exemples d'utilisation

#### 6.1. Démarrage rapide
```bash
# 1. Créer plusieurs projets (automatique)
./manage_projects.sh add site1
./manage_projects.sh add boutique 8085

# 2. Vérifier l'état des sites
./manage_projects.sh site-list

# 3. Accéder aux services
curl http://localhost/         # Page d'accueil
curl http://localhost/site1/   # Site1
```

#### 6.2. Gestion avancée
```bash
# Désactiver un site sans supprimer le conteneur
./manage_projects.sh site-disable boutique

# Créer un site pour un projet existant
./manage_projects.sh site-create ancien-projet

# Supprimer complètement un site
./manage_projects.sh site-remove ancien-site
```

---

## Partie 2 : Infrastructure cible (LXD + Docker)

### 1. Prérequis
- LXD installé et initialisé sur la machine hôte

### 2. Déploiement automatique sous LXD
Utilisez le script `deploy_lxd.sh` :

```bash
chmod +x deploy_lxd.sh
sudo ./deploy_lxd.sh nom_projet port_web
```

Le script va :
- Créer deux conteneurs LXD (web et db) sous Ubuntu 22.04
- Installer Apache HTTPD et MariaDB
- Monter un dossier partagé `/srv/nom_projet_www`
- Configurer la sécurité (iptables)

### 3. Sécurité (Bonus)
- Règles iptables strictes dans les conteneurs LXD
- Accès base de données restreint au serveur web correspondant

---

## Scripts et fichiers

### Scripts principaux
- **`manage_projects.sh`** : Gestion complète des projets Docker (★ Recommandé)
- `deploy.sh` : Déploiement classique avec Docker run
- `deploy_lxd.sh` : Déploiement sous LXD (Partie 2)

### Fichiers de configuration
- `docker-compose.yml` : Configuration générée automatiquement
- `Dockerfile.httpd` : Image Apache personnalisée (optionnelle)
- `Dockerfile.mariadb` : Image MariaDB personnalisée (optionnelle)
- `Dockerfile.nginx` : Image Nginx pour le reverse proxy

---

## Guide de démarrage rapide ⚡

1. **Cloner/télécharger** le projet
2. **Rendre exécutable** : `chmod +x manage_projects.sh`
3. **Créer des projets** : `./manage_projects.sh add site1` (déploiement automatique)
4. **Vérifier les sites** : `./manage_projects.sh site-list`
5. **Accéder** : `http://localhost/` (page d'accueil avec liste des projets)

### 📚 Documentation disponible
- **[TUTORIEL.md](TUTORIEL.md)** - Guide pas à pas complet avec exemples ⭐
- **[GUIDE-RAPIDE.md](GUIDE-RAPIDE.md)** - Référence rapide des commandes
- **`./demo.sh`** - Démonstration interactive du système
- **`./manage_projects.sh --help`** - Aide contextuelle

## Avantages de cette solution ✨

✅ **Gestion granulaire** - Activation/désactivation des sites indépendamment  
✅ **Architecture professionnelle** - Système sites-available/sites-enabled  
✅ **Automatisation complète** - Un script pour tout gérer  
✅ **Pas de conflits** - Gestion automatique des ports  
✅ **Scalabilité** - Ajout facile de nouveaux projets  
✅ **Page d'accueil dynamique** - Vue d'ensemble avec statut  
✅ **Simplicité** - Images officielles, configuration automatique  
✅ **Flexibilité** - Accès multiple (ports directs, sous-domaines, sous-répertoires)

---

## Nouvelles commandes disponibles 🔧

### Gestion des projets
```bash
./manage_projects.sh add <nom>         # Créer un projet
./manage_projects.sh remove <nom>      # Supprimer un projet
./manage_projects.sh modify <nom> <port> # Modifier le port
./manage_projects.sh list              # Lister les projets
```

### Gestion des sites nginx
```bash
./manage_projects.sh site-list         # État des sites
./manage_projects.sh site-enable <nom> # Activer un site
./manage_projects.sh site-disable <nom> # Désactiver un site
./manage_projects.sh site-create <nom> # Créer un site
./manage_projects.sh site-remove <nom> # Supprimer un site
```

### Options avancées
```bash
./manage_projects.sh --no-deploy add site3  # Sans déploiement auto
./manage_projects.sh proxy                  # Reconfigurer le proxy
```  

---

## Dépannage 🛠️

**Voir l'état des sites :**
```bash
./manage_projects.sh site-list  # Statut des sites nginx
./manage_projects.sh list       # Liste des projets/conteneurs
docker ps                       # État des conteneurs
```

**Problème de site nginx :**
```bash
# Recharger la configuration nginx
docker exec reverse_proxy nginx -s reload

# Tester la configuration
docker exec reverse_proxy nginx -t

# Logs nginx
docker logs reverse_proxy
```

**Problème de ports en conflit :**
```bash
./manage_projects.sh list             # Voir les ports utilisés
./manage_projects.sh modify site1 8085 # Changer le port
```

**Problème de déploiement :**
```bash
docker compose down
docker compose up -d --remove-orphans
```

**Réinitialiser un site :**
```bash
./manage_projects.sh site-disable monsite
./manage_projects.sh site-enable monsite
```

**Nettoyer complètement :**
```bash
docker compose down -v  # Supprime aussi les volumes
rm -rf nginx_config/sites-enabled/*  # Reset des sites
```

**Reconstruire le reverse proxy :**
```bash
docker compose build reverse_proxy
docker compose up -d reverse_proxy
```

---

## 🆕 Fonctionnalités spéciales du système sites-available/sites-enabled

### Page d'accueil intelligente
La page d'accueil (`http://localhost/`) affiche automatiquement :
- Liste de tous les projets avec liens directs
- Statut d'activation de chaque site (✓ activé / ✗ désactivé)
- Ports directs pour l'accès aux conteneurs
- Lien vers la page de statut détaillée

### Gestion flexible des sites
```bash
# Scénario : Maintenance d'un site
./manage_projects.sh site-disable boutique    # Site hors ligne
# Le conteneur continue de tourner, seul nginx ne le sert plus

./manage_projects.sh site-enable boutique     # Remise en ligne
# Retour immédiat sans redémarrage de conteneur
```

### Double accès aux sites
Chaque projet est accessible via :
1. **Sous-répertoire** : `http://localhost/monsite/`
2. **Sous-domaine** : `http://monsite.localhost/` (si configuré dans `/etc/hosts`)
3. **Port direct** : `http://localhost:8080`

### Configuration automatique
- Création automatique des sites lors de l'ajout de projets
- Mise à jour de la page d'accueil à chaque modification
- Rechargement automatique de nginx
- Liens symboliques gérés automatiquement

### Architecture évolutive
Le système permet d'ajouter facilement :
- SSL/TLS avec Let's Encrypt
- Load balancing entre plusieurs conteneurs
- Authentification par site
- Limitation de débit
- Headers de sécurité personnalisés
