#!/bin/bash
# Script de gestion des projets dans docker-compose.yml
# Usage: ./manage_projects.sh [add|remove|modify|list|proxy] [nom_projet] [port_web]

set -e

COMPOSE_FILE="docker-compose.yml"
AUTO_DEPLOY=true

# Vérifier les options globales
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-deploy)
            AUTO_DEPLOY=false
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Fonction d'aide
show_help() {
    echo "Usage: $0 [OPTIONS] [COMMANDE] [ARGUMENTS]"
    echo ""
    echo "Options globales:"
    echo "  --no-deploy                    - Ne pas lancer docker compose automatiquement"
    echo ""
    echo "Commandes:"
    echo "  add <nom_projet> [port_web]    - Ajouter un nouveau projet (port auto si non spécifié)"
    echo "  remove <nom_projet>            - Supprimer un projet existant"
    echo "  modify <nom_projet> <port_web> - Modifier le port d'un projet"
    echo "  list                           - Lister tous les projets"
    echo "  proxy                          - Ajouter/Mettre à jour le reverse proxy"
    echo ""
    echo "Commandes de gestion des sites nginx:"
    echo "  site-list                      - Lister tous les sites et leur statut"
    echo "  site-create <nom_projet>       - Créer un site pour un projet"
    echo "  site-remove <nom_site>         - Supprimer un site"
    echo ""
    echo "Exemples:"
    echo "  $0 add site1                   # Port automatique + déploiement auto"
    echo "  $0 --no-deploy add site1       # Port automatique sans déploiement"
    echo "  $0 add site1 8085              # Port spécifique + déploiement auto"
    echo "  $0 remove site1"
    echo "  $0 modify site1 8081"
    echo "  $0 proxy                       # Configure le reverse proxy pour tous les projets"
    echo "  $0 list"
    echo "  $0 site-list                   # Voir le statut de tous les sites"
}

# Fonction pour vérifier si un projet existe
project_exists() {
    local project_name=$1
    grep -q "${project_name}_web:" "$COMPOSE_FILE" 2>/dev/null
}

# Fonction pour lister les projets
list_projects() {
    echo "Projets existants dans $COMPOSE_FILE:"
    if [ -f "$COMPOSE_FILE" ]; then
        local has_projects=false
        grep "container_name:" "$COMPOSE_FILE" | grep "_web" | sed 's/.*container_name: \(.*\)_web/\1/' | while read project; do
            port=$(grep -A 10 "container_name: ${project}_web" "$COMPOSE_FILE" | grep "ports:" -A 2 | grep -o "[0-9]*:80" | cut -d: -f1)
            echo "  - $project (port: $port)"
            has_projects=true
        done
    else
        echo "Aucun fichier docker-compose.yml trouvé."
    fi
}

# Fonction pour trouver le premier port disponible
find_next_available_port() {
    local port=8080
    
    while [ $port -lt 9000 ]; do
        if ! grep -q "\"$port:80\"" "$COMPOSE_FILE" 2>/dev/null; then
            echo $port
            return
        fi
        port=$((port + 1))
    done
    
    echo "Erreur: Aucun port disponible trouvé entre 8080 et 8999"
    exit 1
}

# Fonction pour ajouter un projet
add_project() {
    local project_name=$1
    local port_web=$2
    
    if [ -z "$project_name" ]; then
        echo "Erreur: nom_projet requis"
        show_help
        exit 1
    fi
    
    # Convertir le nom en minuscules pour éviter les erreurs Docker
    project_name=$(echo "$project_name" | tr '[:upper:]' '[:lower:]')
    
    # Si aucun port spécifié, trouver automatiquement
    if [ -z "$port_web" ]; then
        port_web=$(find_next_available_port)
        echo "Port automatiquement assigné: $port_web"
    fi
    
    if project_exists "$project_name"; then
        echo "Erreur: Le projet '$project_name' existe déjà"
        exit 1
    fi
    
    # Vérifier si le port est déjà utilisé
    if grep -q "\"$port_web:80\"" "$COMPOSE_FILE" 2>/dev/null; then
        # trouver le nom du projet utilisant ce port
        local existing_project=$(grep -B 5 "\"$port_web:80\"" "$COMPOSE_FILE" | grep "container_name:" | sed 's/.*container_name: \(.*\)_web/\1/')
        echo "Erreur: Le port $port_web est déjà utilisé par le projet '$existing_project'"
        $next_port=$(find_next_available_port)
        echo "Voulez utilise le port suivant disponible: $next_port ? (o/n)"
        read -r CONFIRM
        if [[ $CONFIRM =~ ^[Oo]$ ]]; then
            port_web=$next_port
            echo "Port modifié vers: $port_web"
        else
            echo "Opération annulée. Le projet n'a pas été ajouté."
            exit 1
        fi
    fi
    
    # Créer le dossier du projet
    PROJECT_DIR="projects/${project_name}"
    mkdir -p "$PROJECT_DIR"
    
    # Créer un fichier index.html par défaut
    cat > "$PROJECT_DIR/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Projet ${project_name}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; text-align: center; }
        h1 { color: #333; }
        .info { background: #f0f0f0; padding: 20px; margin: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>Bienvenue sur le projet ${project_name}</h1>
    <div class="info">
        <p>Ce projet est hébergé par Company01</p>
        <p>Port: ${port_web}</p>
        <p>Vous pouvez modifier ce fichier dans: ${PROJECT_DIR}/</p>
    </div>
</body>
</html>
EOF

    # Créer le fichier docker-compose.yml s'il n'existe pas
    if [ ! -f "$COMPOSE_FILE" ]; then
        cat > "$COMPOSE_FILE" << EOF
version: '3.8'

services:

volumes:

networks:
EOF
    fi
    
    # Ajouter le service web avant la section volumes
    sed -i "/^volumes:/i\\
\\
  ${project_name}_web:\\
    image: httpd:latest\\
    container_name: ${project_name}_web\\
    ports:\\
      - \"${port_web}:80\"\\
    volumes:\\
      - ./projects/${project_name}:/usr/local/apache2/htdocs\\
    networks:\\
      - ${project_name}_net\\
\\
  ${project_name}_db:\\
    image: mariadb:latest\\
    container_name: ${project_name}_db\\
    environment:\\
      - MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=1\\
      - MARIADB_DATABASE=${project_name}\\
    volumes:\\
      - ${project_name}_data:/var/lib/mysql\\
    networks:\\
      - ${project_name}_net\\
" "$COMPOSE_FILE"
    
    # Ajouter les volumes s'il n'existe pas
    if ! grep -q "^volumes:" "$COMPOSE_FILE"; then
        echo "" >> "$COMPOSE_FILE"
        echo "volumes:" >> "$COMPOSE_FILE"
    fi
    
    if ! grep -q "^  ${project_name}_data:" "$COMPOSE_FILE"; then
        sed -i "/^volumes:/a\\
  ${project_name}_data:" "$COMPOSE_FILE"
    fi
    
    # Ajouter les réseaux s'il n'existe pas
    if ! grep -q "^networks:" "$COMPOSE_FILE"; then
        echo "" >> "$COMPOSE_FILE"
        echo "networks:" >> "$COMPOSE_FILE"
    fi
    
    if ! grep -q "^  ${project_name}_net:" "$COMPOSE_FILE"; then
        sed -i "/^networks:/a\\
  ${project_name}_net:" "$COMPOSE_FILE"
    fi
    
    echo "Projet '$project_name' ajouté avec succès (port: $port_web)"
    echo "📁 Dossier du projet: $PROJECT_DIR"
    echo "📝 Fichier index.html créé automatiquement"
    
    # Lancer automatiquement docker compose si activé
    if [ "$AUTO_DEPLOY" = true ]; then
        echo "Lancement de l'infrastructure avec docker compose..."
        if docker compose up -d --remove-orphans; then
            echo "✅ Infrastructure déployée avec succès"
            echo "🌐 Accès au projet: http://localhost:$port_web"
            if grep -q "reverse_proxy:" "$COMPOSE_FILE"; then
                echo "🔄 Reverse proxy: http://localhost/$project_name/"
                echo "📋 Page d'accueil: http://localhost/"
            fi
        else
            echo "❌ Erreur lors du déploiement de l'infrastructure"
            exit 1
        fi
    else
        echo "💡 Pour déployer l'infrastructure: docker compose up -d"
    fi
}

# Fonction pour supprimer un projet
remove_project() {
    local project_name=$1
    
    if [ -z "$project_name" ]; then
        echo "Erreur: nom_projet requis"
        show_help
        exit 1
    fi
    
    # Convertir le nom en minuscules
    project_name=$(echo "$project_name" | tr '[:upper:]' '[:lower:]')
    
    if ! project_exists "$project_name"; then
        echo "Erreur: Le projet '$project_name' n'existe pas"
        exit 1
    fi
    
    # Supprimer les services web et db
    sed -i "/^  ${project_name}_web:/,/^  [a-zA-Z]/{ /^  [a-zA-Z]/!d; /^  ${project_name}_web:/d; }" "$COMPOSE_FILE"
    sed -i "/^  ${project_name}_db:/,/^  [a-zA-Z]/{ /^  [a-zA-Z]/!d; /^  ${project_name}_db:/d; }" "$COMPOSE_FILE"
    
    # Supprimer les volumes
    sed -i "/^  ${project_name}_data:/d" "$COMPOSE_FILE"
    
    # Supprimer le réseau
    sed -i "/^  ${project_name}_net:/d" "$COMPOSE_FILE"
    
    # Supprimer le réseau du reverse proxy s'il existe
    if grep -q "container_name: reverse_proxy" "$COMPOSE_FILE"; then
        sed -i "/container_name: reverse_proxy/,/^  [a-zA-Z]/ s/      - ${project_name}_net//" "$COMPOSE_FILE"
    fi
    
    # Demander si supprimer le dossier du projet
    read -p "Voulez-vous aussi supprimer le dossier du projet projects/${project_name}/ ? (o/n) " CONFIRM
    if [[ $CONFIRM =~ ^[Oo]$ ]]; then
        rm -rf "projects/${project_name}"
        echo "Dossier du projet supprimé"
    fi
    
    echo "Projet '$project_name' supprimé avec succès"
    
    # Supprimer le fichier de configuration nginx s'il existe
    if [ -f "nginx_config/sites-available/${project_name}" ]; then
        rm "nginx_config/sites-available/${project_name}"
        echo "Configuration nginx supprimée"
    fi
    
}

# Fonction pour modifier un projet
modify_project() {
    local project_name=$1
    local new_port=$2
    
    if [ -z "$project_name" ] || [ -z "$new_port" ]; then
        echo "Erreur: nom_projet et nouveau_port requis"
        show_help
        exit 1
    fi
    
    if ! project_exists "$project_name"; then
        echo "Erreur: Le projet '$project_name' n'existe pas"
        exit 1
    fi
    
    # Vérifier si le nouveau port est déjà utilisé (sauf pour ce projet)
    if grep -q "\"$new_port:80\"" "$COMPOSE_FILE" && ! grep -A 5 "container_name: ${project_name}_web" "$COMPOSE_FILE" | grep -q "\"$new_port:80\""; then
        echo "Erreur: Le port $new_port est déjà utilisé par un autre projet"
        exit 1
    fi
    
    # Modifier le port
    sed -i "/container_name: ${project_name}_web/,/networks:/ s/\"[0-9]*:80\"/\"$new_port:80\"/" "$COMPOSE_FILE"
    
    echo "Port du projet '$project_name' modifié vers $new_port"
    
    # Mettre à jour automatiquement le reverse proxy s'il existe
}

# Main
case "${1:-}" in
    add)
        add_project "$2" "$3"
        ;;
    remove)
        remove_project "$2"
        ;;
    modify)
        modify_project "$2" "$3"
        ;;
    list)
        list_projects
        ;;
    proxy)
        add_reverse_proxy
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Erreur: Commande inconnue"
        show_help
        exit 1
        ;;
esac
