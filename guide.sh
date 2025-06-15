#!/bin/bash
# 🧭 Guide d'orientation pour la documentation
# Usage: ./guide.sh

echo "🧭 === GUIDE D'ORIENTATION DOCUMENTATION ==="
echo
echo "Bonjour ! Que souhaitez-vous faire ?"
echo
echo "1) 📚 Apprendre le système de zéro (recommandé pour débutants)"
echo "2) 🎪 Voir une démonstration interactive"
echo "3) 📋 Accès rapide aux commandes"
echo "4) 📖 Lire la documentation complète"
echo "5) ❓ Aide contextuelle du script"
echo "6) 🗂️  Voir tous les documents disponibles"
echo
read -p "Votre choix (1-6) : " choice

case $choice in
    1)
        echo
        echo "📚 Excellent choix ! Le tutoriel vous attend..."
        echo "📁 Fichier: TUTORIEL.md"
        echo
        if command -v less >/dev/null 2>&1; then
            echo "📖 Ouverture du tutoriel..."
            sleep 1
            less TUTORIEL.md
        else
            echo "💡 Utilisez: cat TUTORIEL.md ou votre éditeur préféré"
        fi
        ;;
    2)
        echo
        echo "🎪 Lancement de la démonstration interactive..."
        echo "📁 Script: demo.sh"
        echo
        if [ -x "./demo.sh" ]; then
            ./demo.sh
        else
            echo "❌ Script demo.sh non trouvé ou non exécutable"
            echo "💡 Essayez: chmod +x demo.sh && ./demo.sh"
        fi
        ;;
    3)
        echo
        echo "📋 Guide de référence rapide..."
        echo "📁 Fichier: GUIDE-RAPIDE.md"
        echo
        if command -v less >/dev/null 2>&1; then
            less GUIDE-RAPIDE.md
        else
            echo "💡 Utilisez: cat GUIDE-RAPIDE.md"
        fi
        ;;
    4)
        echo
        echo "📖 Documentation complète..."
        echo "📁 Fichier: README.md"
        echo
        if command -v less >/dev/null 2>&1; then
            less README.md
        else
            echo "💡 Utilisez: cat README.md"
        fi
        ;;
    5)
        echo
        echo "❓ Aide contextuelle du script..."
        echo
        ./manage_projects.sh --help
        ;;
    6)
        echo
        echo "🗂️  Documents disponibles:"
        echo
        ls -1 *.md 2>/dev/null | while read file; do
            echo "  📄 $file"
        done
        if [ -f "demo.sh" ]; then
            echo "  🎪 demo.sh (démonstration)"
        fi
        if [ -f "manage_projects.sh" ]; then
            echo "  ⚙️  manage_projects.sh (script principal)"
        fi
        echo
        echo "💡 Consultez INDEX.md pour plus de détails"
        ;;
    *)
        echo
        echo "❌ Choix invalide. Relancez ./guide.sh"
        exit 1
        ;;
esac

echo
echo "🎯 Autres options disponibles:"
echo "  ./guide.sh           - Revoir ce menu"
echo "  ./demo.sh            - Démonstration"
echo "  ./manage_projects.sh --help - Aide du script principal"
