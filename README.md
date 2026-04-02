------------------------------------------------------------------------------------------------------
ATELIER FROM IMAGE TO CLUSTER
------------------------------------------------------------------------------------------------------
L’idée en 30 secondes : Cet atelier consiste à **industrialiser le cycle de vie d’une application** simple en construisant une **image applicative Nginx** personnalisée avec **Packer**, puis en déployant automatiquement cette application sur un **cluster Kubernetes** léger (K3d) à l’aide d’**Ansible**, le tout dans un environnement reproductible via **GitHub Codespaces**.
L’objectif est de comprendre comment des outils d’Infrastructure as Code permettent de passer d’un artefact applicatif maîtrisé à un déploiement cohérent et automatisé sur une plateforme d’exécution.
  
-------------------------------------------------------------------------------------------------------
Séquence 1 : Codespace de Github
-------------------------------------------------------------------------------------------------------
Objectif : Création d'un Codespace Github  
Difficulté : Très facile (~5 minutes)
-------------------------------------------------------------------------------------------------------
**Faites un Fork de ce projet**. Si besion, voici une vidéo d'accompagnement pour vous aider dans les "Forks" : [Forker ce projet](https://youtu.be/p33-7XQ29zQ) 
  
Ensuite depuis l'onglet [CODE] de votre nouveau Repository, **ouvrez un Codespace Github**.
  
---------------------------------------------------
Séquence 2 : Création du cluster Kubernetes K3d
---------------------------------------------------
Objectif : Créer votre cluster Kubernetes K3d  
Difficulté : Simple (~5 minutes)
---------------------------------------------------
Vous allez dans cette séquence mettre en place un cluster Kubernetes K3d contenant un master et 2 workers.  
Dans le terminal du Codespace copier/coller les codes ci-dessous etape par étape :  

**Création du cluster K3d**  
```
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```
```
k3d cluster create lab \
  --servers 1 \
  --agents 2
```
**vérification du cluster**  
```
kubectl get nodes
```
**Déploiement d'une application (Docker Mario)**  
```
kubectl create deployment mario --image=sevenajay/mario
kubectl expose deployment mario --type=NodePort --port=80
kubectl get svc
```
**Forward du port 80**  
```
kubectl port-forward svc/mario 8080:80 >/tmp/mario.log 2>&1 &
```
**Réccupération de l'URL de l'application Mario** 
Votre application Mario est déployée sur le cluster K3d. Pour obtenir votre URL cliquez sur l'onglet **[PORTS]** dans votre Codespace et rendez public votre port **8080** (Visibilité du port).
Ouvrez l'URL dans votre navigateur et jouer !

---------------------------------------------------
Séquence 3 : Exercice
---------------------------------------------------
Objectif : Customisez un image Docker avec Packer et déploiement sur K3d via Ansible
Difficulté : Moyen/Difficile (~2h)
---------------------------------------------------  
Votre mission (si vous l'acceptez) : Créez une **image applicative customisée à l'aide de Packer** (Image de base Nginx embarquant le fichier index.html présent à la racine de ce Repository), puis déployer cette image customisée sur votre **cluster K3d** via **Ansible**, le tout toujours dans **GitHub Codespace**.  

**Architecture cible :** Ci-dessous, l'architecture cible souhaitée.   
  
![Screenshot Actions](Architecture_cible.png)   
  
---------------------------------------------------  
## Processus de travail (résumé)

1. Installation du cluster Kubernetes K3d (Séquence 1)
2. Installation de Packer et Ansible
3. Build de l'image customisée (Nginx + index.html)
4. Import de l'image dans K3d
5. Déploiement du service dans K3d via Ansible
6. Ouverture des ports et vérification du fonctionnement

---------------------------------------------------
Séquence 4 : Documentation  
Difficulté : Facile (~30 minutes)
---------------------------------------------------
**Complétez et documentez ce fichier README.md** pour nous expliquer comment utiliser votre solution.  
Faites preuve de pédagogie et soyez clair dans vos expliquations et processus de travail.  

Rapport d'Atelier : From Image to Cluster
Objectif du projet

L'objectif de cet atelier était d’automatiser la création d’une image applicative personnalisée et son déploiement sur un cluster Kubernetes (K3d) en utilisant une approche Infrastructure as Code avec Packer et Ansible. Le but était de construire une image Nginx contenant un fichier index.html, puis de la déployer automatiquement dans Kubernetes.

Stack Technique

Environnement : GitHub Codespaces (Ubuntu)
Orchestrateur : K3d (Kubernetes léger)
Build Image : Packer (plugin Docker)
Automatisation : Ansible
Serveur Web : Nginx customisé

Pré-requis

Avant de commencer, installation des dépendances nécessaires :

Bash :
pip3 install kubernetes
ansible-galaxy collection install kubernetes.core

Déploiement de la solution

Le déploiement se fait en plusieurs étapes.

Création du cluster Kubernetes :

Bash :
k3d cluster create mycluster -p "30080:30080@loadbalancer"

Build de l’image

J’ai utilisé Packer pour créer une image Docker personnalisée à partir de Nginx en y intégrant le fichier index.html.

Bash :
cd packer
packer init .
packer build .
cd ..

Cette étape génère une image appelée custom-nginx:v1, prête à être utilisée sans configuration supplémentaire.

Import de l’image dans K3d

L’image doit être importée dans le cluster pour que Kubernetes puisse l’utiliser.

Bash :
k3d image import custom-nginx:v1 -c mycluster

Sans cette étape, les pods ne peuvent pas démarrer car Kubernetes ne trouve pas l’image.

Déploiement avec Ansible

Le déploiement est automatisé avec Ansible, ce qui évite de lancer les commandes Kubernetes manuellement.

Bash :
cd ansible
ansible-playbook -i inventory.ini deploy.yml
cd ..

Le playbook crée :

un Deployment pour lancer le conteneur
un Service pour exposer l’application
Vérification du fonctionnement

Une fois le déploiement terminé, vérification des ressources Kubernetes :

Bash :
kubectl get pods
kubectl get svc
kubectl get deployment

Les pods doivent être en état Running.

Accès à l’application

Dans GitHub Codespaces, l’accès se fait via un port-forward :

Bash :
kubectl port-forward svc/nginx-custom-service 30080:80

Puis ouvrir dans le navigateur :
http://localhost:30080

La page index.html s’affiche correctement.

Structure des fichiers

Le projet est organisé de la manière suivante :

packer : contient la configuration de build de l’image
ansible : contient le playbook et les templates Kubernetes
index.html : page web déployée
Explication technique

Packer permet de créer une image immuable contenant directement l’application, ce qui garantit un déploiement identique à chaque fois.

Ansible permet d’automatiser le déploiement et d’assurer un état stable du cluster. Le playbook peut être relancé sans provoquer d’erreurs, ce qui correspond au principe d’idempotence.

Kubernetes (K3d) permet d’orchestrer l’exécution de l’application via des pods et de l’exposer via un service.

Cycle de vie DevOps

Le projet suit le cycle :

Build → Deploy → Run

Build : création de l’image avec Packer
Deploy : déploiement avec Ansible
Run : exécution dans Kubernetes
Conclusion

Ce projet m’a permis de comprendre comment automatiser un déploiement complet, de la création d’une image Docker jusqu’à son exécution dans un cluster Kubernetes, en combinant plusieurs outils DevOps dans un pipeline cohérent.

La mise en place d'un makefile et d'un script m'a permis d'automatiser la mise en place.
---------------------------------------------------
Evaluation
---------------------------------------------------
Cet atelier, **noté sur 20 points**, est évalué sur la base du barème suivant :  
- Repository exécutable sans erreur majeure (4 points)
- Fonctionnement conforme au scénario annoncé (4 points)
- Degré d'automatisation du projet (utilisation de Makefile ? script ? ...) (4 points)
- Qualité du Readme (lisibilité, erreur, ...) (4 points)
- Processus travail (quantité de commits, cohérence globale, interventions externes, ...) (4 points) 


