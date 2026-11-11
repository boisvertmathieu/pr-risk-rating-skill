<!-- pr-risk-rating:v1 -->
## 🟠 Cote de risque : Élevée (69/100)

> **En bref :** Exemple fictif : la PR 36 de `atelier-imaginaire/traitement-fictif` modifie la validation de lots et leur transformation pour plusieurs consommateurs. Le score de 69/100 impose Élevée ; le second regard confirme ce niveau, sans chemin obligatoire ni irréversibilité établis.

### Grille d'évaluation

| Critère | Poids | Note (0-5) | Constat |
|---|---|---|---|
| Zones sensibles (auth, sécurité, paiements, données) | 25 % | 4 | `src/traitement/validation-lots-fictifs.ts` valide des entrées non fiables ; ce scénario ne modifie ni authentification, ni autorisations, ni chemin déclaré sensible. |
| Migrations et données | 20 % | 3 | `src/traitement/conversion-lots-fictifs.ts` réécrit un ensemble borné de lots ; une restauration des données est étayée dans le scénario. |
| Taille et étendue du diff | 15 % | 4 | 780 lignes ajoutées ou supprimées dans 14 fichiers et 3 composants : réception, validation et transformation. |
| Couverture de tests | 15 % | 4 | Les cas simples ont des résultats fictifs fournis ; le scénario important de reprise après interruption n’a aucun test. |
| API publique et contrats | 10 % | 3 | Le rejet des lots incomplets change de sémantique ; les consommateurs sont identifiés dans `docs/contrat-lots-fictifs.md`. |
| Dépendances | 10 % | 2 | Mise à jour mineure du parseur de lots, verrou cohérent mais interactions à examiner. |
| Réversibilité | 5 % | 3 | Retour applicatif manuel documenté mais non répété de bout en bout, malgré la restauration de données vérifiée séparément. |

### Principaux facteurs de risque
1. Une erreur de validation pourrait accepter un lot mal formé ou rejeter des lots valides chez plusieurs consommateurs.
2. Une interruption peut laisser une transformation partielle ; la reprise du traitement n’est pas testée.
3. Le second regard confirme un rayon d’explosion déjà couvert par les notes élevées ; la réécriture est bornée et restaurable.

### Recommandations avant la fusion
- [ ] Faire examiner la validation et les contrats par les responsables des trois composants et des consommateurs.
- [ ] Ajouter et exécuter des tests d’interruption, de reprise et d’entrées mal formées.
- [ ] Répéter l’annulation complète sur des lots fictifs représentatifs et préciser le déclencheur d’arrêt dans la PR.

### Limites de l'analyse
Sortie entièrement fictive, remplie selon le gabarit provisoire ; dépôt, PR, chemins, SHA et résultats annoncés sont inventés. Analyse statique accompagnée uniquement des éléments fictifs décrits ; aucune exécution réelle de tests ou de restauration. Une migration irréversible ou un chemin déclaré sensible imposerait Critique. La cote vise seulement le commit indiqué et doit être refaite après de nouveaux commits. Elle ne vaut pas approbation de fusion et ne remplace aucun avis humain requis.

---
<sub>Échelle : 🟢 Faible (0-24) · 🟡 Modérée (25-49) · 🟠 Élevée (50-74) · 🔴 Critique (75-100) · Commit analysé : `33334444` · Mis à jour à chaque nouvelle analyse</sub>
