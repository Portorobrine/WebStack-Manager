#!/bin/bash
# Script de migration de nginx vers Traefik

echo "🔄 Migration de nginx vers Traefik"
echo "==================================="

# Sauvegarder l'ancienne configuration
if [ -d "nginx_config" ]; then
    echo "💾 Sauvegarde de l'ancienne configuration nginx..."
    mv nginx_config nginx_config.backup
    echo "✅ Sauvegarde créée : nginx_config.backup"
fi

# Nettoyer les anciens Dockerfiles
old_files=(
    "Dockerfile.nginx"
    "nginx-manager.sh"
)

for file in "${old_files[@]}"; do
    if [ -f "$file" ]; then
        echo "🗑️  Suppression de $file (plus nécessaire avec Traefik)"
        mv "$file" "${file}.backup"
    fi
done

# Mise à jour du .gitignore
if [ -f ".gitignore" ]; then
    # Ajouter des exclusions spécifiques à Traefik
    if ! grep -q "# Traefik" .gitignore; then
        cat >> .gitignore << 'EOF'

# Traefik
traefik.log
acme.json

# Sauvegardes de migration
*.backup
nginx_config.backup/
EOF
        echo "✅ .gitignore mis à jour"
    fi
fi

echo ""
echo "🎉 Migration terminée !"
echo ""
echo "🚀 Prochaines étapes :"
echo "  1. docker compose up -d"
echo "  2. Accéder à http://localhost/ (page d'accueil)"
echo "  3. Accéder à http://localhost:8080/ (dashboard Traefik)"
echo "  4. Ajouter des projets : ./manage_projects.sh add nom-projet"
echo ""
echo "📋 Avantages de Traefik :"
echo "  ✅ Configuration automatique par labels"
echo "  ✅ Dashboard intégré"
echo "  ✅ Support SSL/HTTPS (configurable)"
echo "  ✅ Reload automatique sans redémarrage"
echo ""
echo "🔙 En cas de problème, restaurez avec :"
echo "  mv nginx_config.backup nginx_config"
