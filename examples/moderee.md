<!-- pr-risk-rating:v1 -->
## 🟡 Cote de risque : MODÉRÉE (29/100)

> **En bref :** Exemple fictif : la PR 24 de `atelier-imaginaire/catalogue-fictif` change la durée de vie d’un cache partagé de listes publiques. Le score est de 29/100, soit MODÉRÉE ; le second regard ne relève aucun facteur insuffisamment noté justifiant un rehaussement.

### Grille d'évaluation

| Critère | Poids | Note (0-5) | Constat |
|---|---|---|---|
| Zones sensibles (auth, sécurité, paiements, données) | 25 % | 2 | `src/cache/listes-fictives.ts` conserve uniquement des listes publiques, sans donnée privée ni chemin déclaré sensible. |
| Migrations et données | 20 % | 0 | Aucune migration ; seules des entrées de cache expirables sont affectées. |
| Taille et étendue du diff | 15 % | 2 | 124 lignes ajoutées ou supprimées dans 4 fichiers d’un même composant. |
| Couverture de tests | 15 % | 3 | Tests d’expiration présents dans `tests/cache/listes-fictives.test.ts`, résultats non disponibles ; concurrence non couverte. |
| API publique et contrats | 10 % | 1 | Durée de vie interne modifiée ; le contrat public des listes reste compatible. |
| Dépendances | 10 % | 0 | Aucun manifeste ni verrou modifié. |
| Réversibilité | 5 % | 2 | Indicateur de durée de vie vérifié dans les éléments fictifs fournis ; les anciennes entrées subsistent jusqu’à expiration. |

### Principaux facteurs de risque
1. Une durée trop longue peut exposer des listes périmées pendant plusieurs minutes.
2. Des expirations simultanées peuvent provoquer un pic de requêtes vers la source des listes.
3. Le second regard confirme un cache public borné ; aucun chemin d’authentification ni effet entre clients privés identifié.

### Recommandations avant la fusion
- [ ] Fournir les résultats des tests d’expiration et ajouter un scénario d’accès concurrents.
- [ ] Vérifier le comportement en cas de panne de la source et mesurer le pic de requêtes à expiration.
- [ ] Documenter dans la PR tests, risque de données périmées et retour à la durée précédente avec expiration des entrées.

### Limites de l'analyse
Sortie entièrement fictive, remplie selon le gabarit approuvé ; dépôt, PR, chemins et SHA inventés. Analyse statique ; les résultats de tests automatisés ne sont pas fournis et aucune charge réelle n’a été mesurée. La vérification de l’indicateur est un élément du scénario fictif, pas une exécution réalisée ici. La cote vise seulement le commit indiqué et doit être refaite après de nouveaux commits. Elle ne vaut pas approbation de fusion et ne remplace aucun avis humain requis.

---
<sub>Échelle : 🟢 Faible (0-24) · 🟡 Modérée (25-49) · 🟠 Élevée (50-74) · 🔴 Critique (75-100) · Commit analysé : `22223333` · Mis à jour à chaque nouvelle analyse</sub>
