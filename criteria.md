# Critères et calcul

La cote mesure les conséquences possibles du changement. L’identité de l’auteur n’entre jamais dans les notes. Relever les chemins, comportements, tests et mécanismes d’annulation qui justifient chaque note.

## Grille pondérée

Chaque critère reçoit une note entière de **0 à 5** : 0 signifie aucun enjeu identifié sur ce critère, 5 un enjeu maximal. Une absence de preuve ne constitue pas une preuve d’absence de risque. Les repères suivants concernent le comportement modifié, pas seulement le nom du fichier.

| Critère | Poids | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|---|---|
| Zones sensibles (auth, sécurité, paiements, données) | 25 % | Aucun comportement sensible | Effet interne isolé | Cache ou invite système à exposition limitée | Frontière de confiance ou données partagées | Contrôle de sécurité ou accès à des données sensibles | Authentification, facturation ou contrôle critique transversal |
| Migrations et données | 20 % | Aucun changement de données ou de schéma | Ajout facultatif sans réécriture | Migration additive compatible | Réécriture bornée avec restauration vérifiée | Réécriture large ou compatibilité fragile | Suppression irréversible, perte ou corruption possible |
| Taille et étendue du diff | 15 % | Texte seulement, aucun comportement | Jusqu’à 50 lignes et 2 fichiers, un composant | 51–200 lignes ou 3–5 fichiers | 201–500 lignes, 6–10 fichiers ou 2 composants | 501–1 000 lignes, 11–20 fichiers ou 3 composants | Plus de 1 000 lignes, plus de 20 fichiers, plus de 3 composants ou effet transversal difficile à borner |
| Couverture de tests | 15 % | Aucun comportement changé, ou preuves complètes adaptées au risque | Cas principaux et limites étayés, lacune mineure | Cas principaux couverts, quelques limites manquent | Tests partiels, résultats indisponibles ou couverture inconnue | Scénario important sans test ou tests pertinents en échec | Aucun filet crédible pour un changement à fort impact |
| API publique et contrats | 10 % | Aucun contrat modifié | Détail interne compatible | Extension publique compatible | Sémantique modifiée, consommateurs identifiés | Rupture partielle ou consommateurs mal connus | Rupture publique sans transition |
| Dépendances | 10 % | Aucun changement | Correctif isolé, verrou cohérent | Mise à jour mineure ou outil de construction borné | Nouvelle dépendance d’exécution ou version majeure isolée | Graphe large, provenance ou compatibilité incertaine | Chargement privilégié ou chaîne de dépendances non maîtrisée |
| Réversibilité | 5 % | Aucun effet persistant ; annulation immédiate | Retour au commit précédent suffisant et documenté | Indicateur ou retour de version testé, quelques effets résiduels | Procédure manuelle documentée, non vérifiée | Restauration complexe ou interruption nécessaire | Aucune annulation réaliste, effet irréversible |

Pour la taille, compter ajouts **et** suppressions. Choisir la plus haute note déclenchée par le volume, le nombre de fichiers ou l’étendue des composants ; pour un changement de comportement, chaque dimension commence à 1. Les fichiers générés peuvent amplifier les totaux : expliquer leur rôle et examiner leurs sources ; ne pas masquer un changement de comportement derrière leur volume. Un diff textuel massif sans comportement reste à 0 sur ce critère si cette absence d’effet est établie. Les effets transversaux et binaires justifient une note élevée même avec peu de lignes.

Les notes de tests mesurent le manque de protection **adaptée au changement**. Une assertion ajoutée n’établit pas la couverture d’une panne distribuée. Sans résultats disponibles, retenir au moins 3 lorsqu’un comportement change ; passer à 4 ou 5 selon les scénarios non protégés. Signaler séparément tests présents, tests exécutés et résultats constatés.

## Calcul et seuils

`score brut = somme(note / 5 × poids)` ; les poids sont les nombres 25, 20, 15, 15, 10, 10 et 5, dont la somme vaut 100. Arrondir à l’entier le plus proche, les demis vers le haut : `plancher(score brut + 0,5)`. Avec ces poids et des notes entières, le résultat est déjà entier. Ne pas renormaliser les poids ni omettre un critère ; un critère sans enjeu reçoit 0.

| Score sur 100 | Niveau calculé |
|---|---|
| 0–24 | 🟢 Faible |
| 25–49 | 🟡 Modérée |
| 50–74 | 🟠 Élevée |
| 75–100 | 🔴 Critique |

Exemple de calcul, dans l’ordre du gabarit : notes `(2, 0, 2, 3, 1, 0, 2)` → `10 + 0 + 6 + 9 + 2 + 0 + 2 = 29`, donc Modérée avant rehaussements.

## Planchers et second regard

Appliquer ces règles **après le calcul**, sans changer le score affiché :

1. **Faible** convient aux documents, textes, fonctionnalités internes seulement et ajouts derrière un indicateur lorsque l’isolation est démontrée. Un indicateur désactivé ne protège pas d’une migration exécutée au déploiement, d’un démarrage modifié ou d’un chemin partagé.
2. Un changement produit ordinaire avec effet observable a un plancher **Modérée**. Les modifications du comportement d’un cache, du mécanisme de mise à jour automatique ou des invites système ont aussi ce plancher. Cela reprend les zones sensibles de l’échelle de référence, sans les rendre automatiquement critiques.
3. Un chemin sensible d’authentification, facturation, CI ou installeur, ou une migration irréversible, ne peut **jamais rester Faible**. Pour ce skill, la règle plus forte suivante fixe directement le plancher **Critique** : tout chemin déclaré sensible par les propriétaires, tout fichier de workflow CI, authentification, facturation, CI et workflows de publication, installeurs, migration destructive ou effet difficilement réversible. Une simple modification de texte dans un workflow CI reste soumise à cette règle. Un chemin de documentation décrivant l’authentification n’est pas, à lui seul, un chemin d’authentification ; vérifier son rôle et les déclarations des propriétaires.
4. Le **second regard** relit le diff et son contexte après ce premier classement : ce changement précis présente-t-il un facteur sous-estimé ? Exemples : cache partagé entre clients, nouvel appel privilégié dans un petit diff, annulation dépendant d’un service tiers, effets cumulés sur plusieurs composants. Il peut rehausser **d’un cran**, au maximum Critique, au-dessus du niveau obtenu après les planchers. Justifier par un élément concret ; ne pas compter deux fois un risque déjà correctement noté. Ne jamais abaisser un plancher ni un niveau calculé.

Le niveau final est donc au moins le maximum du niveau calculé et des planchers applicables, puis éventuellement un cran au-dessus. Le titre garde **le score calculé**, même si son intervalle ne correspond plus au niveau. Expliquer dans « En bref » le niveau initial, le chemin ou effet imposant le plancher et tout rehaussement du second regard. Par exemple, `Critique (11/100)` est correct pour une petite modification de workflow CI ; inventer un score de 75 ne l’est pas.

## Chemins sensibles et attention humaine

Exemples indicatifs à adapter au dépôt :

- `src/auth/**`, `src/permissions/**`, `src/securite/**` : authentification, autorisations ou sécurité ; vérifier le rôle exact de chaque chemin.
- `src/facturation/**`, `src/paiements/**` : tarification, factures et mouvements de fonds.
- `.github/workflows/**`, `.github/actions/**`, `ci/**`, `publication/**` : workflows CI, actions locales, construction et publication.
- `installeurs/**`, `scripts/installer.*` : installation et exécution privilégiée.
- `migrations/**`, `schema/**` : transformations de données, surtout suppressions et réécritures.
- `src/cache/**`, `src/mise-a-jour/**`, `invites/systeme/**` : plancher Modérée pour le comportement ; Critique si un autre rôle ou une déclaration des propriétaires l’impose.
- Tout autre chemin explicitement marqué sensible par les propriétaires, même absent de cette liste.

Les chemins imposant une personne ou deux personnes dans les règles du dépôt conservent cette exigence : une cote d’agent ne compte pas comme un de ces avis. Authentification, facturation, CI et publication, installeurs et chemins déclarés sensibles exigent toujours une attention humaine. Pour une migration destructive ou un impact irréversible, demander aussi une revue humaine avant fusion. Respecter tout nombre supérieur de personnes exigé par les propriétaires ; ne pas prétendre qu’une règle universelle impose deux personnes partout.

## Effort de revue et informations manquantes

- **Faible** : vérifier l’isolation, les liens ou textes et l’absence d’effet caché ; des tests automatisés peuvent être sans objet pour des documents seulement.
- **Modérée** : examiner les cas limites et interactions, demander des tests ciblés et une annulation claire.
- **Élevée** : revue approfondie des composants et contrats affectés, scénarios de défaillance, résultats de tests et vérification de l’annulation.
- **Critique** : revue humaine obligatoire des éléments concernés, vérification des protections, des données et du plan de restauration ; appliquer les exigences des propriétaires.

Le rayon d’explosion fixe la barre : un défaut local réversible et une corruption touchant tous les consommateurs n’exigent pas les mêmes preuves. Une description de PR utile couvre tests, risques et annulation ; son absence doit devenir une recommandation concrète. Si un diff ou son contexte manque, qualifier l’analyse de partielle, donner une cote provisoire prudente avec notes justifiées et demander les éléments manquants ; ne jamais présenter le résultat comme exhaustif.
