# Projet PRBD 2526 - ReserVite

Application mobile de gestion de réservations de restaurants développée individuellement dans le cadre de mon Bachelier en Informatique de gestion à l'EPFC.

## Présentation

ReserVite est une application permettant de gérer les réservations d'un restaurant selon deux profils : client et manager.

Le projet a été réalisé individuellement dans le cadre du cours de Projet de bases de données.

Il m'a permis de travailler sur une application Flutter complète reliée à une base de données PostgreSQL, avec gestion de l'état via Riverpod.

## Fonctionnalités principales

### Côté client

- Consultation et recherche de restaurants
- Création et gestion de réservations
- Modification et annulation de réservations
- Consultation des détails d'une réservation

### Côté manager

- Gestion des restaurants
- Consultation des réservations du restaurant
- Modification et annulation des réservations
- Attribution de tables aux réservations
- Gestion de l'état des réservations

## Technologies utilisées

- Flutter
- Dart
- Riverpod
- PostgreSQL
- PL/pgSQL

## Architecture

L'application est séparée en deux parties :

- un frontend développé avec Flutter et Dart ;
- un backend basé sur PostgreSQL et PL/pgSQL.

Le frontend utilise Riverpod pour la gestion de l'état de l'application.

## État du projet

Projet académique partiellement finalisé. Les principales fonctionnalités de réservation et de gestion ont été développées, mais certaines fonctionnalités prévues n'ont pas été implémentées.

# Documentation originale du projet

# Projet PRBD 2526 - Groupe a08 - ReserVite

## Notes de version

### Liste des bugs connus

* bug 1: après avoir modifié une réservation, lors du retour à la page des détails de la réservation(client), 
         la modification a bien eu lieu mais la page n'est pas refresh, les précédents le sont correctement.
         Une fois de retour sur la page des détails, elle est alors rafraichie

* bug 2: après avoir assigné la(les) table(s) à une réservation, lors du retour à la page des détails de la réservation(manager),
         l'assignation a bien eu lieu mais la page n'est pas refresh, les précédents le sont correctement.
         Une fois de retour sur la page des détails, elle est alors rafraichie

* bug 3: la liste des tables assignées n'est pas correcte, identique pour toutes les réservations du restaurant ou aucune(s) affichées

* bug 4: complete reservation était fonctionnel lors de son implémentation. 
         je constate juste avant la remise ça donne une erreur, faute de temps pour trouver la solution...

### Liste des fonctionnalités non implémentées

6 - time travel
7 - manager: CRUD services
7 - manager: CRUD tables

### Divers

...
