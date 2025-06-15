#!/bin/bash
# Script de validation des opérations manuelles
# Usage: ./validate-manual-ops.sh [nom_projet]

set -e

COMPOSE_FILE="docker-compose.yml"
PROJECTS_DIR="projects"
DATA_DIR="data"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions d'affichage
success() { echo -e "${GREEN}✅ $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# Validation de la syntaxe YAML
validate_yaml() {
    info "Validation de la syntaxe docker-compose.yml..."
    if docker compose config > /dev/null 2>&1; then
        success "Syntaxe YAML valide"
    else
        error "Erreur de syntaxe YAML !"
        docker compose config 2>&1 | head -5
        return 1
    fi
}

# Lister tous les projets détectés
list_all_projects() {
    info "Projets détectés dans docker-compose.yml :"
    
    if [ -f "$COMPOSE_FILE" ]; then
        projects=$(grep "container_name: .*_web" "$COMPOSE_FILE" 2>/dev/null | sed 's/.*: \(.*\)_web/\1/' || true)
        if [ -n "$projects" ]; then
            echo "$projects" | while read -r project; do
                echo "  - $project"
            done
        else
            warning "Aucun projet trouvé dans docker-compose.yml"
        fi
    else
        error "Fichier docker-compose.yml introuvable"
    fi
}

# Validation d'un projet spécifique
validate_project() {
    local project="$1"
    
    info "Validation du projet '$project'..."
    
    # Vérifier la présence dans docker-compose.yml
    if grep -q "container_name: ${project}_web" "$COMPOSE_FILE" 2>/dev/null; then
        success "Service ${project}_web trouvé dans docker-compose.yml"
    else
        error "Service ${project}_web manquant dans docker-compose.yml"
        return 1
    fi
    
    if grep -q "container_name: ${project}_db" "$COMPOSE_FILE" 2>/dev/null; then
        success "Service ${project}_db trouvé dans docker-compose.yml"
    else
        error "Service ${project}_db manquant dans docker-compose.yml"
        return 1
    fi
    
    # Vérifier le réseau
    if grep -q "^  ${project}_net:" "$COMPOSE_FILE" 2>/dev/null; then
        success "Réseau ${project}_net trouvé dans docker-compose.yml"
    else
        error "Réseau ${project}_net manquant dans docker-compose.yml"
        return 1
    fi
    
    # Vérifier les répertoires
    if [ -d "$PROJECTS_DIR/$project" ]; then
        success "Répertoire projects/$project existe"
        
        if [ -f "$PROJECTS_DIR/$project/index.html" ]; then
            success "Fichier index.html trouvé"
        else
            warning "Fichier index.html manquant"
        fi
    else
        error "Répertoire projects/$project manquant"
        return 1
    fi
    
    if [ -d "$DATA_DIR/$project" ]; then
        success "Répertoire data/$project existe"
    else
        error "Répertoire data/$project manquant"
        return 1
    fi
    
    # Vérifier l'état des containers
    if docker compose ps | grep -q "${project}_web.*Up"; then
        success "Container ${project}_web en cours d'exécution"
    else
        warning "Container ${project}_web non démarré"
    fi
    
    if docker compose ps | grep -q "${project}_db.*Up"; then
        success "Container ${project}_db en cours d'exécution"
    else
        warning "Container ${project}_db non démarré"
    fi
    
    # Test de connectivité web
    info "Test de connectivité web..."
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost/$project/" | grep -q "200"; then
        success "Accès web fonctionnel : http://localhost/$project/"
    else
        warning "Accès web non fonctionnel ou service non démarré"
    fi
}

# Validation globale de l'environnement
validate_environment() {
    info "Validation de l'environnement global..."
    
    # Vérifier que Traefik est présent et protégé
    if grep -q "container_name: traefik" "$COMPOSE_FILE" 2>/dev/null; then
        success "Service Traefik trouvé"
    else
        error "Service Traefik manquant !"
        return 1
    fi
    
    if grep -q "^  traefik:" "$COMPOSE_FILE" 2>/dev/null; then
        success "Réseau traefik protégé"
    else
        error "Réseau traefik manquant !"
        return 1
    fi
    
    # Vérifier l'état de Traefik
    if docker compose ps | grep -q "traefik.*Up"; then
        success "Container Traefik en cours d'exécution"
        
        # Test API Traefik
        if curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/api/overview" | grep -q "200"; then
            success "API Traefik accessible : http://localhost:8080/"
        else
            warning "API Traefik non accessible"
        fi
    else
        error "Container Traefik non démarré"
        return 1
    fi
    
    # Vérifier les Dockerfiles
    if [ -f "Dockerfile.httpd" ]; then
        success "Dockerfile.httpd présent"
    else
        error "Dockerfile.httpd manquant"
    fi
    
    if [ -f "Dockerfile.mariadb" ]; then
        success "Dockerfile.mariadb présent"
    else
        error "Dockerfile.mariadb manquant"
    fi
}

# Validation de suppression
validate_removal() {
    local project="$1"
    
    info "Validation de la suppression du projet '$project'..."
    
    # Vérifier que le projet n'existe plus
    if ! grep -q "container_name: ${project}_web" "$COMPOSE_FILE" 2>/dev/null; then
        success "Service ${project}_web supprimé du docker-compose.yml"
    else
        error "Service ${project}_web encore présent dans docker-compose.yml"
        return 1
    fi
    
    if ! grep -q "^  ${project}_net:" "$COMPOSE_FILE" 2>/dev/null; then
        success "Réseau ${project}_net supprimé"
    else
        error "Réseau ${project}_net encore présent"
        return 1
    fi
    
    # Vérifier que les répertoires sont supprimés
    if [ ! -d "$PROJECTS_DIR/$project" ]; then
        success "Répertoire projects/$project supprimé"
    else
        error "Répertoire projects/$project encore présent"
    fi
    
    if [ ! -d "$DATA_DIR/$project" ]; then
        success "Répertoire data/$project supprimé"
    else
        error "Répertoire data/$project encore présent"
    fi
    
    # Vérifier que les containers sont arrêtés
    if ! docker compose ps | grep -q "${project}_web"; then
        success "Container ${project}_web supprimé"
    else
        warning "Container ${project}_web encore actif"
    fi
    
    # Vérifier que Traefik est toujours là
    if grep -q "^  traefik:" "$COMPOSE_FILE" 2>/dev/null; then
        success "Réseau traefik préservé"
    else
        error "Réseau traefik supprimé par erreur !"
        return 1
    fi
}

# Fonction principale
main() {
    echo "🔍 Validation des opérations manuelles"
    echo "======================================"
    
    # Validation de base
    validate_yaml || exit 1
    validate_environment || exit 1
    
    if [ -n "$1" ]; then
        if [ "$2" = "--removed" ]; then
            validate_removal "$1"
        else
            validate_project "$1"
        fi
    else
        list_all_projects
        
        echo ""
        info "Usage:"
        echo "  $0                     # Validation globale"
        echo "  $0 nom-projet         # Validation d'un projet"
        echo "  $0 nom-projet --removed # Validation de suppression"
    fi
    
    echo ""
    success "Validation terminée"
}

# Exécution
main "$@"
