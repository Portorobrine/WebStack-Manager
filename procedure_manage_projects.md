# Guide d'utilisation - manage_projects.sh

## Utilisation

### Créer un projet
```bash
./manage_projects.sh add nom-projet
```

**Exemple :**
```bash
./manage_projects.sh add ipssi
```

### Supprimer un projet
```bash
./manage_projects.sh remove nom-projet
```

**Exemple :**
```bash
./manage_projects.sh remove ipssi
```

## Structure créée

```
projects/nom-projet/     # Fichiers web (HTML, PHP, etc.)
data/nom-projet/         # Base de données MariaDB
```

## Développement

### Modifier le site
Éditez directement les fichiers dans `projects/nom-projet/`
```bash
nano projects/mon-site/index.html
echo "<?php phpinfo(); ?>" > projects/mon-site/info.php
```

### Accéder à la base de données
```bash
docker exec -it nom-projet_web /bin/bash
mysql -h nom-projet_db -u root nom-projet
```
