# coloc_app
<p align="center"><img src="https://user-images.githubusercontent.com/76879157/226761837-e970231d-7395-46ae-8594-324c95bf1970.png" alt="Image" width="10%" height="auto" /></p>

Ce projet est un projet scolaire réalisé en Flutter qui a pour objectif de gérer des colocations (cçoté colocataire et propriétaire).

## Installation
1. Cloner le dépôt :
```git
git clone https://github.com/istrk33/coloc_app.git
```


1. Cloner le dépôt :
```bash
git clone https://github.com/istrk33/coloc_app.git
```

2. Se déplacer dans le répertoire du projet :
```bash
cd coloc_app
```

3. Installer les dépendances :
```bash
flutter pub get
```

3. Lancer l'application :
```bash
flutter run
```

## Fonctionnalités

Ce projet utilise Flutter pour créer une application mobile multi-plateforme qui contient les fonctionnalités suivantes :
* Créer un compte
* Gestion des propriété
* Gestion des annonces
* Postuler sur une annonce
* Donner le verdict à une candidature
* Gestion des tâches
* Lister les annonces sur une carte ou sous forme de liste
* ...

## Technologies 
Ce projet utilise les technologies suivantes :
* Flutter
* Dart
* Firebase

Contribuer
Les contributions sont les bienvenues ! Voici comment vous pouvez aider :

## Forker le projet
1. Créer une branche pour votre contribution (``git checkout -b ma-contribution`)
2. Commiter vos changements (`git commit -m "Ajouter une fonctionnalité"`)
3. Pousser vers la branche (`git push origin ma-contribution`)
4. Créer une Pull Request

## Configuration de Firebase
Ce projet utilise Firebase pour la gestion des données. Pour utiliser l'application, vous devez créer un projet Firebase et configurer les informations d'identification pour l'application. Voici comment procéder :

1. Créez un projet Firebase dans la console Firebase.
2. Ajoutez une application Flutter à votre projet Firebase.
3. Téléchargez le fichier `google-services.json` et placez-le dans le répertoire `android/app` de votre projet Flutter.
4. Ajoutez le fichier `GoogleService-Info.plist` à votre projet iOS.
5. Initialisez Firebase dans votre application Flutter en ajoutant les plugins nécessaires et en appelant la méthode `Firebase.initializeApp()` dans votre `main()`.

Vous devrez également configurer les règles de sécurité Firebase pour vous assurer que votre application peut accéder aux données correctement. Consultez la documentation Firebase pour plus d'informations sur la configuration de Firebase pour votre projet.

## Démonstration de l'application
Voici une vidéo de démonstration de l'application :

<iframe width="560" height="315" src="https://www.youtube.com/embed/-3SUeu-nhN8" frameborder="0" allowfullscreen></iframe>

## Contributeurs
* https://github.com/RowanMrc
* https://github.com/istrk33
