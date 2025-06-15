#!/bin/bash
# Script de validation de la configuration Traefik

echo "🔍 Validation de la configuration WebStack-Manager avec Traefik"
echo "================================================================"

# Vérifier docker-compose.yml
echo "📋 Vérification du docker-compose.yml..."
if docker compose config > /dev/null 2>&1; then
    echo "✅ docker-compose.yml valide"
else
    echo "❌ Erreur dans docker-compose.yml"
    docker compose config
    exit 1
fi

# Vérifier la structure des fichiers
echo ""
echo "📁 Vérification de la structure des fichiers..."

required_files=(
    "docker-compose.yml"
    "manage_projects.sh"
    "homepage/index.html"
    "README.md"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file présent"
    else
        echo "❌ $file manquant"
    fi
done

# Vérifier les répertoires de projets
echo ""
echo "📂 Projets détectés :"
if [ -d "projects" ]; then
    for project in projects/*/; do
        if [ -d "$project" ]; then
            project_name=$(basename "$project")
            echo "  📁 $project_name"
        fi
    done
else
    echo "  ℹ️  Aucun projet trouvé (dossier projects/ n'existe pas)"
fi

# Vérifier la configuration Traefik dans docker-compose
echo ""
echo "🔍 Vérification de la configuration Traefik..."
if grep -q "traefik:" docker-compose.yml; then
    echo "✅ Service Traefik configuré"
else
    echo "❌ Service Traefik manquant"
fi

if grep -q "traefik.enable=true" docker-compose.yml; then
    echo "✅ Labels Traefik détectés"
else
    echo "❌ Labels Traefik manquants"
fi

echo ""
echo "🎯 Pour tester la configuration :"
echo "  1. docker compose up -d"
echo "  2. curl http://localhost/"
echo "  3. Ouvrir http://localhost:8080/ (Dashboard Traefik)"
echo ""
echo "📚 Pour ajouter un projet :"
echo "  ./manage_projects.sh add nom-projet"
