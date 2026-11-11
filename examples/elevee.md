<!-- pr-risk-rating:v1 -->
## 🟠 Cote de risque : ÉLEVÉE (72/100)

> **En bref :** Exemple entièrement fictif : la PR 36 de `atelier-imaginaire/connexion-fictive` modifie la validation des jetons d’authentification et ajoute une migration irréversible supprimant `legacy_id`, avec peu de tests ajoutés. Le score est de 72/100, soit ÉLEVÉE ; le second regard confirme que ces facteurs sont déjà notés et maintient la recommandation de revue humaine.

### Grille d'évaluation

| Critère | Poids | Note (0-5) | Constat |
|---|---|---|---|
| Zones sensibles (auth, sécurité, paiements, données) | 25 % | 5 | `src/auth/token.ts` modifie la validation de l’expiration des jetons ; le chemin et les comportements décrits sont fictifs. |
| Migrations et données | 20 % | 4 | `migrations/0042_drop_legacy.sql` supprime la colonne `legacy_id` sans sauvegarde dédiée ; cette suppression ciblée est irréversible par retour de version. |
| Taille et étendue du diff | 15 % | 3 | 412 lignes ajoutées ou supprimées dans 14 fichiers et 3 composants fictifs ; note 3 selon le barème. |
| Couverture de tests | 15 % | 4 | Un seul test ajouté pour 6 fonctions modifiées ; aucun test du chemin d’erreur de `refreshToken` ni de l’expiration exacte. |
| API publique et contrats | 10 % | 2 | Champ optionnel ajouté à `/v1/users` ; extension compatible du contrat public fictif. |
| Dépendances | 10 % | 1 | Mise à jour mineure isolée du client HTTP fictif, avec verrou cohérent. |
| Réversibilité | 5 % | 4 | Retour arrière impossible sans restauration de données ; la disponibilité et la procédure de restauration complète restent à vérifier. |

### Principaux facteurs de risque
1. **Validation des jetons** : la vérification de l’expiration passe de `<` à `<=` dans le fichier fictif `src/auth/token.ts:88`.
2. **Migration destructive** : la colonne `legacy_id` est supprimée sans sauvegarde dédiée ; revenir au code précédent ne la restaure pas.
3. **Tests insuffisants** : aucun test pour le chemin d’erreur de `refreshToken` ni pour la borne exacte d’expiration.

### Recommandations avant la fusion
- [ ] Ajouter et exécuter des tests pour l’expiration exacte du jeton et le chemin d’erreur de `refreshToken`.
- [ ] Prévoir une migration en deux temps ou une sauvegarde de `legacy_id`, et vérifier la restauration avant toute suppression.
- [ ] Faire relire la PR par une personne responsable de l’authentification et une personne responsable des migrations, selon les règles du dépôt.

### Limites de l'analyse
Sortie entièrement fictive selon le gabarit approuvé ; dépôt, PR, chemins et SHA inventés, sans valeur de jeton ni donnée réelle. Analyse statique du diff seulement : le code n’a pas été exécuté, les résultats de tests ne sont pas fournis et le contexte hors diff n’a pas été lu en entier. Le score se calcule ainsi : 25 + 16 + 9 + 12 + 4 + 2 + 4 = 72. La cote vise seulement le commit indiqué et doit être refaite après de nouveaux commits ; elle ne vaut pas approbation de fusion et ne remplace aucun avis humain requis.

---
<sub>Échelle : 🟢 Faible (0-24) · 🟡 Modérée (25-49) · 🟠 Élevée (50-74) · 🔴 Critique (75-100) · Commit analysé : `33334444` · Mis à jour à chaque nouvelle analyse</sub>
