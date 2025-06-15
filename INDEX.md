# 📚 Documentation du projet de conteneurisation

## 📋 Index des documents

### 📖 Documentation principale
- **[README.md](README.md)** - Documentation complète du projet
- **[TUTORIEL.md](TUTORIEL.md)** - Guide pas à pas d'utilisation du script ⭐
- **[GUIDE-RAPIDE.md](GUIDE-RAPIDE.md)** - Référence rapide des commandes

### 🎪 Outils interactifs
- **[demo.sh](demo.sh)** - Démonstration interactive du système
- **[manage_projects.sh](manage_projects.sh)** - Script principal de gestion

### 🏗️ Pour commencer rapidement

1. **Débutant complet** → Suivez le [TUTORIEL.md](TUTORIEL.md)
2. **Démonstration rapide** → Lancez `./demo.sh`
3. **Référence rapide** → Consultez [GUIDE-RAPIDE.md](GUIDE-RAPIDE.md)
4. **Documentation complète** → Lisez [README.md](README.md)

### 🎯 Selon votre besoin

| Je veux... | Document recommandé |
|------------|-------------------|
| Apprendre de zéro | [TUTORIEL.md](TUTORIEL.md) |
| Voir une démo | `./demo.sh` |
| Commande rapide | [GUIDE-RAPIDE.md](GUIDE-RAPIDE.md) |
| Architecture complète | [README.md](README.md) |
| Aide contextuelle | `./manage_projects.sh --help` |

### 🔧 Structure du projet

```
projet-compose/
├── 📚 Documentation/
│   ├── README.md           # Documentation principale
│   ├── TUTORIEL.md         # Guide d'apprentissage
│   ├── GUIDE-RAPIDE.md     # Référence rapide
│   └── INDEX.md            # Ce fichier
├── 🎪 Scripts/
│   ├── manage_projects.sh  # Script principal
│   └── demo.sh            # Démonstration
├── 🌐 Configuration nginx/
│   ├── nginx.conf
│   ├── sites-available/
│   └── sites-enabled/
├── 🐳 Docker/
│   ├── docker-compose.yml
│   ├── Dockerfile.nginx
│   └── Dockerfile.httpd
└── 📁 Projets/
    └── projects/
```

---

**🚀 Démarrage recommandé :** `./demo.sh` puis `TUTORIEL.md`
