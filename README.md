# tp-coords-menu

Menu de téléportation (TP) NUI pour FiveM compatible avec l'API Lapsus.

## Fonctionnalités
- Menu latéral gauche épuré avec bouton unique **TP**.
- Fenêtre de saisie des coordonnées **X**, **Y**, **Z**.
- **Ctrl+V intelligent** : Détecte et colle automatiquement les coordonnées sous n'importe quel format (ex: `754, 15.22, 42.1, 69.15`, vector3, etc.) et téléporte instantanément sans avoir besoin d'appuyer sur Entrée.
- Saisie manuelle avec validation par la touche **Entrée**.
- Utilisation de `Lapsus.InjectResource(nil, code)` pour sélectionner automatiquement une ressource disponible.

## Lancement dans Lapsus

Exécutez cette ligne dans votre exécuteur Lapsus :

```lua
load(Lapsus.HttpGet("https://raw.githubusercontent.com/2kslegoat-bit/tp-coords-menu/main/loader.lua"))()
```

Touche par défaut pour ouvrir/fermer le menu : **HOME** (touche Début, modifiable dans `loader.lua`).
