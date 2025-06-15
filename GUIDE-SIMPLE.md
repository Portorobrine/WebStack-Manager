# 🎯 Guide Système Simplifié - Un fichier par projet

## ✅ Problème résolu !
Le site fonctionne maintenant avec un système simplifié où **chaque projet a son propre fichier de configuration nginx**.

## 🏗️ Structure simplifiée

```
nginx_config/
└── 00-main.conf           # Fichier principal (page d'accueil + tous les proxies)
```

## 🔧 Scripts disponibles

### Script principal : `nginx-manager.sh`
```bash
./nginx-manager.sh list           # Voir les configurations
./nginx-manager.sh update         # Regénérer la page d'accueil
./nginx-manager.sh reload         # Recharger nginx
./nginx-manager.sh add monsite    # Ajouter config pour un projet
./nginx-manager.sh remove monsite # Supprimer config d'un projet
```

### Script original : `manage_projects.sh`
```bash
./manage_projects.sh add monsite  # Créer projet complet
./manage_projects.sh list         # Lister les projets Docker
./manage_projects.sh remove site  # Supprimer projet complet
```

## 🌐 Accès aux sites

| URL | Description |
|-----|-------------|
| `http://localhost/` | 🏠 Page d'accueil avec liste des projets |
| `http://localhost/demo/` | 📁 Projet demo via proxy |
| `http://localhost/ipssi/` | 🎓 Projet ipssi via proxy |
| `http://localhost:8080/` | 🔗 Accès direct au projet demo |
| `http://localhost:8081/` | 🔗 Accès direct au projet ipssi |

## 🎯 Workflow simple pour ajouter un projet

### Option 1 : Automatic (recommandé)
```bash
# Le script fait tout automatiquement
./manage_projects.sh add nouveau-site

# La configuration nginx est créée automatiquement
# Le site est accessible sur http://localhost/nouveau-site/
```

### Option 2 : Manuel
```bash
# 1. Ajouter au docker-compose.yml manuellement
# 2. Créer le fichier nginx
./nginx-manager.sh add nouveau-site

# 3. Recharger
./nginx-manager.sh update
```

## 📝 Personnaliser la configuration d'un projet

Chaque projet peut avoir son fichier personnalisé :

```bash
# Créer nginx_config/monsite.conf
cat > nginx_config/monsite.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    
    location /monsite/ {
        proxy_pass http://monsite_web:80/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        
        # Personnalisations spécifiques
        proxy_read_timeout 300;
        client_max_body_size 100M;
    }
}
EOF

# Recharger nginx
./nginx-manager.sh reload
```

## 🛠️ Dépannage rapide

### Site inaccessible
```bash
# Vérifier que nginx fonctionne
curl -I http://localhost/

# Vérifier les configurations
./nginx-manager.sh list

# Recharger nginx
./nginx-manager.sh reload
```

### Problème de configuration
```bash
# Tester la config nginx
docker exec reverse_proxy nginx -t

# Voir les logs
docker logs reverse_proxy | tail -10

# Régénérer la page d'accueil
./nginx-manager.sh update
```

### Repartir de zéro
```bash
# Supprimer toutes les configs nginx
rm nginx_config/*.conf

# Régénérer
./nginx-manager.sh update
```

## ✨ Avantages du nouveau système

- ✅ **Simple** : Un fichier principal contient tout
- ✅ **Modulaire** : Possibilité d'avoir des fichiers séparés si besoin
- ✅ **Automatique** : La page d'accueil se met à jour automatiquement
- ✅ **Flexible** : Facile de personnaliser chaque projet
- ✅ **Debug facile** : Configuration claire et lisible

## 🎉 C'est tout !

Le système fonctionne maintenant. Vous pouvez :
1. Accéder à la page d'accueil : `http://localhost/`
2. Naviguer vers vos projets
3. Ajouter de nouveaux projets facilement
4. Personnaliser les configurations selon vos besoins
