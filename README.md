<div align="center">
  <img src="logo.png" alt="AquaTwin-Drip Logo" width="200"/>
  <h1>🌱 AquaTwin-Drip <sup><span style="font-size: 16px; background-color: #f0f0f0; padding: 2px 8px; border-radius: 4px;">v1.0.0</span></sup></h1>
  <p><strong>Jumeau numérique Hybrid AquaTwin-Drip pour le pilotage de l'irrigation goutte-à-goutte</strong></p>
  <p>Irrigation goutte à goutte • AquaCrop • Solveur 2D axisymétrique • Couplage bidirectionnel fort • Data-Driven AI • Volumes finis en dualité discrète</p>
  
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  [![MATLAB R2024a](https://img.shields.io/badge/MATLAB-orange.svg)](https://www.mathworks.com/)
  [![Python 3.10+](https://img.shields.io/badge/Python--blue.svg)](https://www.python.org/downloads/)
  [![SoilGrids](https://img.shields.io/badge/SoilGrids--brightgreen.svg)]()
  [![Rosetta](https://img.shields.io/badge/Rosetta--blue.svg)]()
  [![Version](https://img.shields.io/badge/Version-1.0.0-red.svg)]()
  [![Status: Prototype](https://img.shields.io/badge/Status-Prototype-brightgreen.svg)]()
  
</div>

---

## 📋 Table des matières

- [À propos](#-à-propos)
- [Version actuelle](#-version-actuelle)
- [Contexte et problématique](#-contexte-et-problématique)
- [Fonctionnalités clés](#-fonctionnalités-clés)
- [Architecture du système](#-architecture-du-système)
- [Démarrage rapide](#-démarrage-rapide)
- [Structure du dépôt](#-structure-du-dépôt)
- [Documentation](#-documentation)
- [Validation et benchmarks](#-validation-et-benchmarks)
- [Équipe](#-équipe)
- [Licence](#-licence)
- [Références](#-références)

---

## 🎯 À propos

**AquaTwin-Drip** est un prototype logiciel open-source développé en MATLAB et Python, conçu pour optimiser la conception et la gestion de l'irrigation goutte-à-goutte en Afrique subsaharienne. Il repose sur un **moteur de simulation hybride** couplant :

- **Un solveur 2D axisymétrique** de l'équation de Richards pour simuler précisément la dynamique des bulbes d'humectation ;
- **Le modèle AquaCrop** de la FAO pour estimer la croissance et le rendement des cultures ;
- **Un couplage bidirectionnel fort** pour capturer les interactions sol–plante en temps réel ;
- **Un module Data-Driven AI** exploitant les données météorologiques globales (NASA POWER Data) pour une planification stratégique ;
- **Intégration de SoilGrids** pour les propriétés pédologiques ;
- **Fonctions de pédotransfert Rosetta** pour estimer les paramètres hydrauliques du sol (conductivité, courbes de rétention) à partir des données SoilGrids.

> **Innovation majeure** :L’innovation de ce projet repose sur une hybridation entre deux approches : la modélisation couplée sol-culture pour mieux représenter les dynamiques hydriques sous irrigation localisée et donc prédire les rendements agricoles ; un module d’optimisation mathématique pour le dimensionnement et la gestion opérationnelle des réseaux d’irrigation, aligné avec les besoins réels des cultures. L’outil permettra donc aux ingénieurs et agriculteurs de dimensionner des réseaux d’irrigation plus efficaces et moins coûteux, et de piloter l’irrigation pour maximiser les rendements tout en minimisant la consommation d’eau et d’énergie. Il pourra automatiquement générer des plans de dimensionnement de réseau adapté à la topologie et des calendriers d’optimisation, ce qui constitue une aide à la décision pour les ingénieurs et les agriculteurs.


---

## 📌 Version actuelle

**Version : 1.0.0** — *Première version stable du prototype*

| Élément | Description |
|---------|-------------|
| **Date de sortie** | Juin 2026 |
| **Statut** | Prototype fonctionnel — prêt pour validation terrain |
| **Compatibilité** | MATLAB R2016b+ / R2024a recommandé, Python 3.10+ |


### ✅ Fonctionnalités incluses dans cette version

| ID | Fonctionnalité | Statut |
|----|----------------|--------|
| 1 | Solveur Richards 2D axisymétrique stabilisé | ✅ |
| 2 | Intégration complète d'AquaCrop-OS (v2.0) | ✅ |
| 3 | Couplage bidirectionnel fort sol ↔ plante | ✅ |
| 4 | Pipeline automatisé SoilGrids → Rosetta | ✅ |
| 5 | Module de validation par données expérimentales | ✅ |
| 6 | Visualisation des bulbes d'humectation (2D/3D) | ✅ |
| 7 | Optimisation automatique des paramètres d'irrigation | ✅ |
| 8 | Export des résultats (CSV, JSON, figures) | ✅ |
| 10 | Interface utilisateur graphique (GUI) | 🚧 À venir |

### 📈 Prochaines étapes

| Version | Objectifs |
|---------|-----------|
| **v1.1.0** | Version opérationnelle avec application web ou mobile |


---

## 🌍 Contexte et problématique

En Afrique subsaharienne, et notamment au Bénin, les décisions d'irrigation reposent souvent sur l'expérience, menant à une utilisation sous-optimale de l'eau. Cette situation est aggravée par :

- Une **forte variabilité climatique** ;
- Des **sols souvent sableux** (ferrallitiques, lixisols) à faible capacité de rétention ;
- Le **manque d'outils adaptés** aux contraintes locales.

L'irrigation goutte-à-goutte est une solution prometteuse, mais son efficacité dépend de la dynamique du **bulbe d'humectation**? une zone d'humidité localisée que les méthodes traditionnelles ne peuvent pas gérer finement.

### 📊 État de l'art et positionnement

| Approche | Limites | Notre solution |
|----------|---------|----------------|
| Modèles agronomiques (AquaCrop) | Ignorent le bulbe d'humectation 2D | Couplage avec solveur Richards 2D |
| Modèles physiques (HYDRUS) | Logiciel fermé, non pilotable | Architecture open-source, moteur pilotable |
| Approches empiriques | Basées sur l'expérience, sous-optimales | Data-Driven AI + optimisation mathématique |
| Données pédologiques | Souvent absentes ou incomplètes | Pipeline SoilGrids + Rosetta |

---

## ⚡ Fonctionnalités clés

<div align="center">

| Fonctionnalité | Description | Statut |
|----------------|-------------|--------|
| 🧮 **Solveur Richards 2D axisymétrique** | Simulation des flux hydriques sous goutteur | ✅ Implémenté |
| 🌿 **Modèle AquaCrop** | Estimation du rendement et du stress hydrique | ✅ Implémenté |
| 🔄 **Couplage bidirectionnel fort** | Échanges itératifs sol ↔ plante | ✅ Implémenté |
| 📊 **Visualisation 3D/2D** | Bulbes d'humectation, profils d'humidité | ✅ Implémenté |
| 📉 **Données limitées** | Fonctionnement avec paramètres pédotransfert | ✅ Implémenté |
| 🌤️ **Data-Driven AI** | Planification stratégique via données globales | ✅ Implémenté |
| 🌍 **SoilGrids intégré** | Accès aux propriétés pédologiques globales | ✅ Implémenté |
| 🔬 **Rosetta pedotransfert** | Estimation des paramètres hydrauliques | ✅ Implémenté |
| 📱 **Interface utilisateur** | Interface ergonomique adaptée aux utilisateurs | 🚧 En développement |

</div>

---

## 🏗️ Architecture du système


### 🧩 Composants logiciels

| Composant | Langage | Rôle |
|-----------|---------|------|
| **Solveur Richards** | MATLAB | Résolution de l'équation de Richards en 2D axisymétrique |
| **AquaCrop** | MATLAB | Modèle de croissance des cultures (FAO) |
| **Moteur de couplage** | MATLAB | Orchestration des échanges bidirectionnels |
| **Data-Driven AI** | Python | Planification stratégique via données globales |
| **Pipeline pédologique** | Python → MATLAB | SoilGrids → Rosetta → paramètres hydrauliques |
| **Visualisation** | Python/MATLAB | Graphiques 2D/3D des résultats |
| **Interface utilisateur** | Python | Interface ergonomique (en développement) |

---

## 🚀 Démarrage rapide

### Prérequis

- **MATLAB** R2020b ou supérieur (recommandé : R2024a)
- **Python** 3.10 ou supérieur
- **Connexion Internet** (pour les API : Open-Meteo, NASA POWER, SoilGrids)

### Installation

```bash
# 1. Cloner le dépôt
git clone https://github.com/Alex542277/AquaTwin-Drip.git
cd AquaTwin-Drip

# 2. Configurer l'environnement Python
python -m venv venv
source venv/bin/activate  # sur Windows : venv\Scripts\activate
pip install -r requirements.txt

# 3. Ajouter le chemin MATLAB
# Dans MATLAB, exécuter :
addpath(genpath('/chemin/vers/AquaTwin-Drip/matlab'))
addpath(genpath('/chemin/vers/AquaTwin-Drip/aquacrop/Code'))
savepath
