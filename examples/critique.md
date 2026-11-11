<!-- pr-risk-rating:v1 -->
## 🔴 Cote de risque : Critique (11/100)

> **En bref :** Exemple fictif : la PR 48 de `atelier-imaginaire/verification-fictive` ajuste le délai d’un workflow CI et son outil de vérification. Le score brut de 11/100 donnerait Faible, mais `.github/workflows/verification-fictive.yml` impose le plancher Critique et une revue humaine ; le second regard confirme ce classement.

### Grille d'évaluation

| Critère | Poids | Note (0-5) | Constat |
|---|---|---|---|
| Zones sensibles (auth, sécurité, paiements, données) | 25 % | 0 | Aucun changement d’authentification, de permission, de paiement ou de donnée ; le chemin CI déclenche néanmoins le plancher obligatoire. |
| Migrations et données | 20 % | 0 | Aucune migration ni donnée persistante modifiée. |
| Taille et étendue du diff | 15 % | 1 | 12 lignes ajoutées ou supprimées dans le workflow et `outils/verificateur-fictif.lock`, au sein d’un seul composant CI. |
| Couverture de tests | 15 % | 2 | Validation de syntaxe et simulation du cas principal étayées dans le scénario ; délai limite non couvert. |
| API publique et contrats | 10 % | 0 | Aucun contrat d’API modifié. |
| Dépendances | 10 % | 1 | Correctif isolé de l’outil de vérification ; fichier de verrou cohérent. |
| Réversibilité | 5 % | 0 | Retour immédiat au workflow précédent, sans effet persistant dans ce scénario. |

### Principaux facteurs de risque
1. Le chemin `.github/workflows/verification-fictive.yml` requiert toujours une attention humaine, même pour un petit diff.
2. Un délai trop court peut interrompre les vérifications de toutes les PR du dépôt fictif.
3. Le second regard ne détecte pas de publication ni de permission nouvelle ; cela ne réduit pas le plancher Critique.

### Recommandations avant la fusion
- [ ] Obtenir la revue humaine du workflow et respecter le nombre de personnes exigé par les règles du dépôt.
- [ ] Vérifier le délai sur le cas le plus lent et le comportement à expiration.
- [ ] Documenter les tests, le risque de vérifications interrompues et le retour au workflow précédent dans la PR.

### Limites de l'analyse
Sortie entièrement fictive, remplie selon le gabarit provisoire ; dépôt, PR, chemins, SHA et validations sont inventés. Analyse statique ; aucun workflow ni outil réel exécuté. Le score de 11 reste affiché sans être artificiellement porté à 75. La cote vise seulement le commit indiqué et doit être refaite après de nouveaux commits. Elle ne vaut pas approbation de fusion et ne remplace jamais la revue humaine obligatoire.

---
<sub>Échelle : 🟢 Faible (0-24) · 🟡 Modérée (25-49) · 🟠 Élevée (50-74) · 🔴 Critique (75-100) · Commit analysé : `44445555` · Mis à jour à chaque nouvelle analyse</sub>
