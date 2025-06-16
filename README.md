# WebStack Manager

Gestionnaire de projets web avec support Docker CLI et Docker Compose, incluant Apache/PHP et MariaDB, avec Traefik comme reverse proxy.

## 🎯 Fonctionnalités

- **Support Docker CLI et Docker Compose** : Deux scripts de gestion distincts
- **Stack LAMP complète** : Apache, PHP, MariaDB intégrés
- **Reverse Proxy Traefik** : Gestion automatique des domaines et SSL
- **Isolation des projets** : Chaque projet a son propre réseau et base de données
- **Gestion du cycle de vie** : Création, suppression et nettoyage automatiques

## 📋 Prérequis

- Docker installé et fonctionnel
- Ports 80 et 8080 libres
- Système Linux/macOS avec bash ou zsh

## 🚀 Utilisation

### Avec Docker CLI (recommandé)
```bash
# Créer un projet
./manage-without-compose.sh add mon-projet

# Créer un autre projet
./manage-without-compose.sh add blog

# Supprimer un projet
./manage-without-compose.sh remove mon-projet
```

### Avec Docker Compose (alternatif)
```bash
# Créer un projet
./manage_projects.sh add mon-projet

# Créer un autre projet
./manage_projects.sh add blog

# Supprimer un projet
./manage_projects.sh remove mon-projet
```

## 🌐 Accès aux Services

- **Site web** : `http://localhost/nom-projet/` (via Traefik)
- **Dashboard Traefik** : `http://localhost:8080`

## � Routing Traefik

Tous les projets sont accessibles uniquement via Traefik :

```bash
# Créer un projet
./manage-without-compose.sh add mon-site

# Accès via Traefik
curl http://localhost/mon-site/
```

### Exemples d'accès
- **Projet "blog"** : `http://localhost/blog/`
- **Projet "shop"** : `http://localhost/shop/`
- **Dashboard Traefik** : `http://localhost:8080`

## 🗃️ Base de Données

Chaque projet dispose de sa propre instance MariaDB avec :

- **Host** : `nom-projet_db`
- **Base de données** : `webapp`
- **Utilisateur** : `webuser`
- **Mot de passe** : `webpassword`
- **Root password** : `rootpassword`

### Exemple de connexion PHP
```php
<?php
$pdo = new PDO("mysql:host=hello_db;dbname=webapp", "webuser", "webpassword");
?>
```

## 📁 Structure des Projets

```
WebStack-Manager/
├── manage-without-compose.sh   # Script Docker CLI
├── manage_projects.sh         # Script Docker Compose
├── docker-entrypoint.sh       # Script d'entrée MariaDB
├── Dockerfile.httpd          # Image Apache/PHP
├── Dockerfile.mariadb        # Image MariaDB personnalisée
├── docker-compose.yml        # Configuration Docker Compose
└── projects/
    └── nom-projet/
        ├── index.html        # Page d'accueil par défaut
        └── *.php            # Fichiers PHP du projet
```

## 🔧 Concepts Techniques Expliqués

### Docker vs LXC
- **Docker** : Conteneurisation légère au niveau applicatif
- **LXC** : Conteneurisation au niveau système (plus proche des VMs)
- Docker utilise des namespaces et cgroups pour l'isolation

### Différences Docker CLI vs Docker Compose
- **Docker CLI** : Commandes directes, plus de contrôle, parfait pour l'apprentissage
- **Docker Compose** : Configuration déclarative, plus simple pour les stacks complexes

### Scripts Bash Utilisés

#### Redirections
- `2>/dev/null` : Redirige stderr vers /dev/null (supprime les erreurs)
- `command || true` : Ignore les codes d'erreur (garde clause)

#### Variables et Fonctions
- `$1, $2, etc.` : Arguments positionnels
- `return` vs `exit` : return sort de la fonction, exit sort du script
- `$(command)` : Substitution de commande

#### Outils de traitement de texte
- `awk` : Traitement de colonnes et patterns
- `grep` : Recherche de motifs
- `sed` : Édition de flux

## 🚨 Diagnostic et Dépannage

### Vérifier l'état des conteneurs
```bash
docker ps -a
```

### Consulter les logs
```bash
docker logs nom-projet_web
docker logs nom-projet_db
```

### Tester la connectivité base de données
```bash
docker exec nom-projet_db mysql -u webuser -pwebpassword -e "SHOW DATABASES;"
```

### Nettoyer complètement
```bash
# Arrêter tous les conteneurs
docker stop $(docker ps -q)

# Supprimer tous les conteneurs
docker rm $(docker ps -aq)

# Supprimer les réseaux orphelins
docker network prune -f
```

## 📚 Ressources et Documentation

- [Documentation Docker](https://docs.docker.com/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Guide MariaDB](https://mariadb.org/documentation/)
- [PHP MySQL Extension](https://www.php.net/manual/en/book.pdo.php)
