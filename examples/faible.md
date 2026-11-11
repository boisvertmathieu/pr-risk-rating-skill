<!-- pr-risk-rating:v1 -->
## 🟢 Cote de risque : Faible (0/100)

> **En bref :** Exemple fictif : la PR 12 de `atelier-imaginaire/guide-fictif` corrige deux pages de documentation sans modifier le comportement du produit. Le score est de 0/100 ; le second regard ne relève aucun plancher ni motif de rehaussement.

### Grille d'évaluation

| Critère | Poids | Note (0-5) | Constat |
|---|---|---|---|
| Zones sensibles (auth, sécurité, paiements, données) | 25 % | 0 | `docs/demarrage-fictif.md` et `docs/options-fictives.md` ne sont ni exécutés ni déclarés sensibles. |
| Migrations et données | 20 % | 0 | Aucun schéma ni fichier de données modifié. |
| Taille et étendue du diff | 15 % | 0 | 18 lignes textuelles modifiées dans 2 fichiers, sans comportement ; note 0 selon le barème. |
| Couverture de tests | 15 % | 0 | Aucun comportement changé ; des tests automatisés supplémentaires sont sans objet. |
| API publique et contrats | 10 % | 0 | Aucun contrat modifié ; les options décrites gardent leur signification. |
| Dépendances | 10 % | 0 | Aucune dépendance ni aucun verrou modifié. |
| Réversibilité | 5 % | 0 | Annulation immédiate des seules corrections de texte, sans effet persistant. |

### Principaux facteurs de risque
1. La documentation pourrait encore contenir une commande erronée malgré la faible portée du diff.
2. Les liens relatifs des deux pages doivent rester valides.
3. Le second regard confirme que ces pages ne sont pas consommées par un générateur de configuration.

### Recommandations avant la fusion
- [ ] Relire les commandes et les noms d’options cités dans les deux pages.
- [ ] Vérifier les liens relatifs après les corrections.
- [ ] Indiquer dans la description de PR que les tests sont sans objet et que l’annulation consiste à rétablir le texte.

### Limites de l'analyse
Sortie entièrement fictive, remplie selon le gabarit provisoire ; dépôt, PR, chemins et SHA inventés. Analyse statique des deux pages ; aucune commande de la documentation exécutée. La cote vise seulement le commit indiqué et doit être refaite après de nouveaux commits. Elle ne vaut pas approbation de fusion et ne remplace aucun avis humain requis.

---
<sub>Échelle : 🟢 Faible (0-24) · 🟡 Modérée (25-49) · 🟠 Élevée (50-74) · 🔴 Critique (75-100) · Commit analysé : `11112222` · Mis à jour à chaque nouvelle analyse</sub>
