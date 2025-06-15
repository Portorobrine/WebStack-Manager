#!/bin/bash
# 🎪 Démonstration interactive du script manage_projects.sh
# Usage: ./demo.sh

echo "🎯 === DÉMONSTRATION DU SYSTÈME DE GESTION DES SITES ==="
echo

# Fonction pour attendre l'entrée utilisateur
wait_user() {
    echo "➡️  Appuyez sur [Entrée] pour continuer..."
    read
}

# Fonction pour exécuter et afficher une commande
run_demo() {
    echo "🔧 Commande: $1"
    echo "---"
    eval $1
    echo
    wait_user
}

echo "Ce script va vous montrer les principales fonctionnalités du système."
echo "Nous allons créer des projets, gérer les sites nginx, et voir l'accès web."
echo
wait_user

echo "📋 1. État initial - vérifions ce qui existe déjà"
run_demo "./manage_projects.sh list"
run_demo "./manage_projects.sh site-list"

echo "🏗️  2. Création de nouveaux projets"
echo "Nous allons créer 3 projets : demo-restaurant, demo-blog, et demo-portfolio"
echo
run_demo "./manage_projects.sh --no-deploy add demo-restaurant"
run_demo "./manage_projects.sh --no-deploy add demo-blog 8085"
run_demo "./manage_projects.sh --no-deploy add demo-portfolio"

echo "📊 3. Vérification après création"
run_demo "./manage_projects.sh list"
run_demo "./manage_projects.sh site-list"

echo "🚀 4. Déploiement de l'infrastructure"
run_demo "docker compose up -d"

echo "🌐 5. Test d'accès aux sites"
echo "Attendons que les conteneurs démarrent..."
sleep 3
run_demo "curl -s http://localhost/ | head -10"

echo "⚙️  6. Gestion des sites"
echo "Liste des sites disponibles"
run_demo "./manage_projects.sh site-list"

echo "🔧 7. Modification d'un projet"
run_demo "./manage_projects.sh modify demo-restaurant 8088"
run_demo "./manage_projects.sh list"

echo "🗑️  8. Nettoyage (optionnel)"
echo "Voulez-vous supprimer les projets de démonstration ? (o/n)"
read -r CLEANUP
if [[ $CLEANUP =~ ^[Oo]$ ]]; then
    echo "Suppression des projets de démonstration..."
    ./manage_projects.sh remove demo-restaurant
    ./manage_projects.sh remove demo-blog  
    ./manage_projects.sh remove demo-portfolio
    echo "Projets de démonstration supprimés."
else
    echo "Projets conservés. Vous pouvez les supprimer plus tard avec:"
    echo "./manage_projects.sh remove demo-restaurant"
    echo "./manage_projects.sh remove demo-blog"
    echo "./manage_projects.sh remove demo-portfolio"
fi

echo
echo "🎉 === DÉMONSTRATION TERMINÉE ==="
echo "Consultez le fichier TUTORIEL.md pour plus de détails."
echo "Utilisez './manage_projects.sh --help' pour voir toutes les commandes disponibles."
