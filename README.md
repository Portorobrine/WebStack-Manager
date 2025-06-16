# WebStack Manager

Un gestionnaire de projets web avec stack LAMP (Linux, Apache, MariaDB, PHP) utilisant Docker et Traefik comme reverse proxy.

## 🚀 Fonctionnalités

- Création et suppression rapide de projets web
- Stack LAMP complète (Apache + MariaDB + PHP)
- Reverse proxy automatique avec Traefik
- Deux modes de gestion : Docker Compose ou commandes Docker directes
- Isolation des projets avec réseaux Docker dédiés
- Accès web via `http://localhost/nom-projet/`

## 📋 Prérequis

- Docker
- Docker Compose (pour le mode compose)
- Bash

## 🛠️ Installation

1. Cloner le projet :
```bash
git clone <repo-url>
cd WebStack-Manager
```

2. Rendre les scripts exécutables :
```bash
chmod +x manage_projects.sh manage-without-compose.sh
```

## 🎯 Utilisation

### Mode Docker Compose (Recommandé)

```bash
# Créer un nouveau projet
./manage_projects.sh add mon-projet

# Supprimer un projet
./manage_projects.sh remove mon-projet
```

### Mode Docker Direct

```bash
# Créer un nouveau projet
./manage-without-compose.sh add mon-projet

# Supprimer un projet
./manage-without-compose.sh remove mon-projet
```

## 📁 Structure du projet

```
WebStack-Manager/
├── README.md
├── docker-compose.yml          # Généré automatiquement
├── .env                        # Configuration de la base de données
├── manage_projects.sh          # Script principal (Docker Compose)
├── manage-without-compose.sh   # Script alternatif (Docker direct)
├── docker-entrypoint.sh        # Script d'initialisation MariaDB
├── Dockerfile.httpd            # Image Apache + PHP
├── Dockerfile.mariadb          # Image MariaDB personnalisée
├── projects/                   # Fichiers web des projets
│   └── [nom-projet]/
│       └── index.html
└── data/                       # Données des bases de données
    └── [nom-projet]/
        └── [fichiers-mysql]
```

## 🌐 Accès aux services

- **Projets web** : `http://localhost/nom-projet/`
- **Dashboard Traefik** : `http://localhost:8080`

## 🔧 Configuration

### Variables d'environnement (.env)

```properties
MARIADB_ROOT_PASSWORD=votre_mot_de_passe_root_super_secret
MARIADB_DATABASE=webapp
MARIADB_USER=webuser
MARIADB_PASSWORD=votre_mot_de_passe_utilisateur_secret
DB_HOST=localhost
DB_PORT=3306
```

### Connexion à la base de données depuis PHP

```php
<?php
$host = 'nom-projet_db';  // Nom du conteneur MariaDB
$dbname = 'nom-projet';   // Nom de la base de données
$username = 'root';
$password = '';           // Mot de passe vide par défaut

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Connexion réussie !";
} catch(PDOException $e) {
    echo "Erreur : " . $e->getMessage();
}
?>
```

## 📝 Exemples

### Créer un projet "blog"

```bash
./manage_projects.sh add blog
```

Cela crée :
- Un conteneur Apache + PHP accessible via `http://localhost/blog/`
- Un conteneur MariaDB avec une base de données "blog"
- Les répertoires `projects/blog/` et `data/blog/`
- Un fichier `projects/blog/index.html` de base

### Développer le projet

1. Modifier les fichiers dans `projects/blog/`
2. Les changements sont visibles immédiatement
3. Accéder à la base de données via le nom d'hôte `blog_db`

## 🐳 Services Docker

### Traefik (Reverse Proxy)
- **Image** : `traefik:v3.0`
- **Ports** : 80 (web), 8080 (dashboard)
- **Réseau** : `traefik`

### Apache + PHP (par projet)
- **Image** : Basée sur `ubuntu:22.04`
- **Packages** : `apache2`, `php`, `libapache2-mod-php`, `php-mysql`
- **Port** : 80 (interne)
- **Réseaux** : `traefik`, `[projet]_net`

### MariaDB (par projet)
- **Image** : Basée sur `ubuntu:22.04`
- **Package** : `mariadb-server`
- **Port** : 3306 (interne)
- **Réseau** : `[projet]_net`

## 🔍 Dépannage

### Vérifier les conteneurs actifs
```bash
docker ps
```

### Voir les logs d'un projet
```bash
docker logs nom-projet_web
docker logs nom-projet_db
```

### Accéder au conteneur
```bash
docker exec -it nom-projet_web bash
docker exec -it nom-projet_db bash
```

### Redémarrer les services
```bash
docker compose restart
```

## 📄 Licence

Ce projet est sous licence libre. Vous pouvez l'utiliser, le modifier et le redistribuer selon vos besoins.
