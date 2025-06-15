# 📝 Guide de Référence Rapide - manage_projects.sh

## 🚀 Commandes essentielles

### Gestion des projets
```bash
./manage_projects.sh add <nom>                    # Créer un projet
./manage_projects.sh add <nom> <port>             # Créer avec port spécifique
./manage_projects.sh --no-deploy add <nom>        # Créer sans déployer
./manage_projects.sh list                         # Lister les projets
./manage_projects.sh modify <nom> <port>          # Changer le port
./manage_projects.sh remove <nom>                 # Supprimer un projet
```

### Gestion des sites nginx
```bash
./manage_projects.sh site-list                   # État des sites
./manage_projects.sh site-enable <nom>           # Activer un site
./manage_projects.sh site-disable <nom>          # Désactiver un site
./manage_projects.sh site-create <nom>           # Créer un site
./manage_projects.sh site-remove <nom>           # Supprimer un site
```

## 🌐 Accès aux sites

| Type d'accès | URL | Description |
|---------------|-----|-------------|
| Page d'accueil | `http://localhost/` | Liste tous les projets |
| Statut | `http://localhost/status` | État des sites |
| Via proxy | `http://localhost/monsite/` | Accès via nginx |
| Port direct | `http://localhost:8080/` | Accès direct au conteneur |
| Sous-domaine | `http://monsite.localhost/` | Nécessite config DNS |

## 🔧 Commandes Docker utiles

```bash
docker compose ps                    # État des conteneurs
docker compose up -d                # Démarrer l'infrastructure
docker compose down                 # Arrêter l'infrastructure
docker compose logs reverse_proxy   # Logs nginx
docker exec reverse_proxy nginx -t  # Tester config nginx
docker exec reverse_proxy nginx -s reload  # Recharger nginx
```

## 📁 Structure des fichiers

```
nginx_config/
├── sites-available/    # Sites configurés
├── sites-enabled/      # Sites actifs (liens symboliques)
└── nginx.conf         # Config nginx principale

projects/
└── monsite/           # Contenu web du projet
    └── index.html
```

## 🛠️ Dépannage express

| Problème | Solution |
|----------|----------|
| Port occupé | `./manage_projects.sh modify <nom> <nouveau_port>` |
| Site inaccessible | `./manage_projects.sh site-enable <nom>` |
| Nginx planté | `docker compose restart reverse_proxy` |
| Config cassée | `docker exec reverse_proxy nginx -t` |

## 📊 Statut des sites

- ✅ **✓ activé** : Site accessible via nginx
- ❌ **✗ désactivé** : Site hors ligne (conteneur actif)

## 🎯 Workflow typique

1. **Créer** : `./manage_projects.sh add monsite`
2. **Vérifier** : `./manage_projects.sh site-list`
3. **Accéder** : `http://localhost/monsite/`
4. **Modifier** : Éditer `projects/monsite/index.html`
5. **Maintenance** : `./manage_projects.sh site-disable monsite`
6. **Relancer** : `./manage_projects.sh site-enable monsite`

## 🎪 Démo interactive

```bash
chmod +x demo.sh
./demo.sh    # Démonstration guidée
```
