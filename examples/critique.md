<!-- pr-risk-rating:v1 -->
## 🔴 Cote de risque : CRITIQUE (91/100)

> **En bref :** Exemple entièrement fictif : la PR 48 de `atelier-imaginaire/facturation-fictive` remplace le calcul des soldes et déclenche une réécriture destructive depuis un workflow de publication. Le score est de 91/100, soit CRITIQUE ; le second regard confirme les risques déjà notés et la nécessité d’une revue humaine des chemins sensibles.

### Grille d'évaluation

| Critère | Poids | Note (0-5) | Constat |
|---|---|---|---|
| Zones sensibles (auth, sécurité, paiements, données) | 25 % | 5 | `src/facturation/calcul-fictif.ts` change les règles de calcul des soldes de tous les comptes fictifs. |
| Migrations et données | 20 % | 5 | `migrations/0100_remplacer-soldes-fictifs.sql` réécrit toutes les valeurs et supprime les historiques, sans solution de restauration crédible identifiée. |
| Taille et étendue du diff | 15 % | 4 | 850 lignes ajoutées ou supprimées dans 18 fichiers et 4 composants : facturation, données, API et publication. |
| Couverture de tests | 15 % | 5 | Aucun test crédible des nouveaux calculs, de la réécriture ou de la reprise après interruption ; aucune exécution de tests attestée. |
| API publique et contrats | 10 % | 4 | Suppression d’un champ de l’API fictive `/v1/soldes` ; compatibilité des consommateurs externes inconnue. |
| Dépendances | 10 % | 3 | Nouvelle dépendance d’exécution : pilote de conversion fictif, sans autre changement du graphe établi. |
| Réversibilité | 5 % | 5 | Historiques supprimés et absence de sauvegarde établie ; aucune annulation réaliste identifiée pour les données réécrites. |

### Principaux facteurs de risque
1. **Rayon d’explosion** : une erreur de calcul affecterait tous les soldes du scénario fictif.
2. **Données irrécupérables** : la suppression des historiques empêche de reconstruire les anciennes valeurs avec les éléments disponibles.
3. **Publication sans filet** : `.github/workflows/publication-fictive.yml` lance la réécriture sans test de reprise ni compatibilité des consommateurs démontrée.

### Recommandations avant la fusion
- [ ] Faire relire la PR par les personnes responsables de la facturation, des migrations et des workflows de publication, selon les règles du dépôt.
- [ ] Préserver les historiques, prévoir une migration compatible en plusieurs étapes et vérifier une sauvegarde ainsi que sa restauration avant toute réécriture.
- [ ] Ajouter et exécuter les tests de calcul, de compatibilité de l’API, d’interruption et de reprise avant de déclencher le workflow.

### Limites de l'analyse
Sortie entièrement fictive selon le gabarit approuvé ; dépôt, PR, fichiers, données et SHA inventés. Analyse statique seulement ; aucun calcul réel, workflow, test ou restauration exécuté. Le score se calcule ainsi : 25 + 20 + 12 + 15 + 8 + 6 + 5 = 91 ; aucun rehaussement n’est nécessaire. La cote vise seulement le commit indiqué et doit être refaite après de nouveaux commits ; elle ne vaut pas approbation de fusion et ne remplace jamais les avis humains requis.

---
<sub>Échelle : 🟢 Faible (0-24) · 🟡 Modérée (25-49) · 🟠 Élevée (50-74) · 🔴 Critique (75-100) · Commit analysé : `44445555` · Mis à jour à chaque nouvelle analyse</sub>
