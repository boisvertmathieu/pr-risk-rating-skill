# Critères et calcul

La cote mesure les conséquences possibles du changement. L’identité de l’auteur n’entre jamais dans les notes. Relever les chemins, comportements, tests et mécanismes d’annulation qui justifient chaque note.

## Grille pondérée

Chaque critère reçoit une note entière de **0 à 5** : 0 signifie aucun enjeu identifié sur ce critère, 5 un enjeu maximal. Une absence de preuve ne constitue pas une preuve d’absence de risque. Les repères suivants concernent le comportement modifié, pas seulement le nom du fichier.

| Critère | Poids | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|---|---|
| Zones sensibles (auth, sécurité, paiements, données) | 25 % | Aucun comportement sensible | Effet interne isolé | Cache ou invite système à exposition limitée | Frontière de confiance ou données partagées | Contrôle de sécurité ou accès à des données sensibles | Authentification, facturation ou contrôle critique transversal |
| Migrations et données | 20 % | Aucun changement de données ou de schéma | Ajout facultatif sans réécriture | Migration additive compatible | Réécriture bornée avec restauration vérifiée | Réécriture large, compatibilité fragile ou suppression ciblée irréversible par retour de version | Perte ou corruption étendue sans solution de restauration crédible |
| Taille et étendue du diff | 15 % | Texte seulement, aucun comportement | Jusqu’à 50 lignes et 2 fichiers, un composant | 51–200 lignes ou 3–5 fichiers | 201–500 lignes, 6–15 fichiers ou 2–3 composants | 501–1 000 lignes, 16–20 fichiers ou 4 composants | Plus de 1 000 lignes, plus de 20 fichiers, plus de 4 composants ou effet transversal difficile à borner |
| Couverture de tests | 15 % | Aucun comportement changé, ou preuves complètes adaptées au risque | Cas principaux et limites étayés, lacune mineure | Cas principaux couverts, quelques limites manquent | Tests partiels, résultats indisponibles ou couverture inconnue | Scénario important sans test ou tests pertinents en échec | Aucun filet crédible pour un changement à fort impact |
| API publique et contrats | 10 % | Aucun contrat modifié | Détail interne compatible | Extension publique compatible | Sémantique modifiée, consommateurs identifiés | Rupture partielle ou consommateurs mal connus | Rupture publique sans transition |
| Dépendances | 10 % | Aucun changement | Correctif ou mise à jour mineure isolée, verrou cohérent | Mise à jour mineure étendue ou outil de construction borné | Nouvelle dépendance d’exécution ou version majeure isolée | Graphe large, provenance ou compatibilité incertaine | Chargement privilégié ou chaîne de dépendances non maîtrisée |
| Réversibilité | 5 % | Aucun effet persistant ; annulation immédiate | Retour au commit précédent suffisant et documenté | Indicateur ou retour de version testé, quelques effets résiduels | Procédure manuelle documentée, non vérifiée | Restauration complexe ou interruption nécessaire | Aucune annulation réaliste, effet irréversible |

Pour la taille, compter ajouts **et** suppressions. Choisir la plus haute note déclenchée par le volume, le nombre de fichiers ou l’étendue des composants ; pour un changement de comportement, chaque dimension commence à 1. Les fichiers générés peuvent amplifier les totaux : expliquer leur rôle et examiner leurs sources ; ne pas masquer un changement de comportement derrière leur volume. Un diff textuel massif sans comportement reste à 0 sur ce critère si cette absence d’effet est établie. Les effets transversaux et binaires justifient une note élevée même avec peu de lignes.

Les notes de tests mesurent le manque de protection **adaptée au changement**. Une assertion ajoutée n’établit pas la couverture d’une panne distribuée. Sans résultats disponibles, retenir au moins 3 lorsqu’un comportement change ; passer à 4 ou 5 selon les scénarios non protégés. Signaler séparément tests présents, tests exécutés et résultats constatés.

## Calcul et seuils

`score brut = somme(note / 5 × poids)` ; les poids sont les nombres 25, 20, 15, 15, 10, 10 et 5, dont la somme vaut 100. Arrondir à l’entier le plus proche, les demis vers le haut : `plancher(score brut + 0,5)`. Avec ces poids et des notes entières, le résultat est déjà entier. Ne pas renormaliser les poids ni omettre un critère ; un critère sans enjeu reçoit 0.

| Score sur 100 | Niveau calculé |
|---|---|
| 0–24 | 🟢 FAIBLE |
| 25–49 | 🟡 MODÉRÉE |
| 50–74 | 🟠 ÉLEVÉE |
| 75–100 | 🔴 CRITIQUE |

Exemple de calcul, dans l’ordre du gabarit : notes `(2, 0, 2, 3, 1, 0, 2)` → `10 + 0 + 6 + 9 + 2 + 0 + 2 = 29`, donc Modérée avant rehaussements.

Le scénario de l’exemple élevée reçoit les notes `(5, 4, 3, 4, 2, 1, 4)` : `25 + 16 + 9 + 12 + 4 + 2 + 4 = 72`, donc **ÉLEVÉE**. Une suppression ciblée de colonne est à 4 sur migrations ; 412 lignes dans 14 fichiers et 3 composants sont à 3 sur taille ; une mise à jour mineure isolée est à 1 sur dépendances. La revue humaine recommandée pour l’authentification et la migration ne modifie pas le résultat numérique.

## Classement et second regard

Le niveau affiché suit le score et les seuils ci-dessus. Aucun chemin, type de changement ou besoin d’avis humain ne déclenche de niveau minimum automatique.

Les documents, textes, fonctionnalités internes et ajouts derrière un indicateur peuvent présenter peu de risques si leur isolation est établie. Un indicateur désactivé ne protège pas d’une migration exécutée au déploiement, d’un démarrage modifié ou d’un chemin partagé. Le produit ordinaire, le cache, la mise à jour automatique et les invites système méritent un examen des interactions ; noter leurs effets réels sans leur attribuer automatiquement un niveau.

Le **second regard** relit le diff et son contexte après le classement numérique : ce changement précis présente-t-il un facteur concret insuffisamment capturé par la grille ? Exemples : cache partagé entre clients, nouvel appel privilégié dans un petit diff, annulation dépendant d’un service tiers, effets cumulés sur plusieurs composants. Il peut rehausser **d’un seul cran**, au maximum CRITIQUE, uniquement si ce facteur n’est pas déjà bien noté. Ne pas compter deux fois un même risque, ne pas abaisser le niveau calculé et ne pas cumuler plusieurs rehaussements.

En cas de rehaussement, garder le score calculé et expliquer dans « En bref » le niveau numérique initial, le facteur concret mal capturé et le niveau final. Le niveau peut alors exceptionnellement dépasser l’intervalle du score ; les seuils ne changent pas. Sans ce motif distinct, conserver le niveau du score, même pour l’authentification ou une migration irréversible. Une recommandation de revue humaine accompagne les chemins sensibles indépendamment du niveau.

## Chemins sensibles et attention humaine

Exemples indicatifs à adapter au dépôt :

- `src/auth/**`, `src/permissions/**`, `src/securite/**` : authentification, autorisations ou sécurité ; vérifier le rôle exact de chaque chemin.
- `src/facturation/**`, `src/paiements/**` : tarification, factures et mouvements de fonds.
- `.github/workflows/**`, `.github/actions/**`, `ci/**`, `publication/**` : workflows CI, actions locales, construction et publication.
- `installeurs/**`, `scripts/installer.*` : installation et exécution privilégiée.
- `migrations/**`, `schema/**` : transformations de données, surtout suppressions et réécritures.
- `src/cache/**`, `src/mise-a-jour/**`, `invites/systeme/**` : examiner les interactions et l’exposition ; recommander une revue humaine si les propriétaires les déclarent sensibles ou si leur rôle l’exige.
- Tout autre chemin explicitement marqué sensible par les propriétaires, même absent de cette liste.

Les chemins imposant une personne ou deux personnes dans les règles du dépôt conservent cette exigence : une cote d’agent ne compte pas comme un de ces avis. Pour l’authentification, la facturation, la CI et la publication, les installeurs, les chemins déclarés sensibles, une migration destructive ou un impact irréversible, inscrire une recommandation de revue humaine dans « Recommandations avant la fusion ». Tout fichier de workflow CI reçoit cette recommandation, même pour une modification de texte. Respecter le nombre de personnes exigé par les propriétaires ; ne pas prétendre qu’une règle universelle impose deux personnes partout. Cette attention humaine n’impose pas CRITIQUE ni aucun autre niveau.

## Effort de revue et informations manquantes

- **Faible** : vérifier l’isolation, les liens ou textes et l’absence d’effet caché ; des tests automatisés peuvent être sans objet pour des documents seulement.
- **Modérée** : examiner les cas limites et interactions, demander des tests ciblés et une annulation claire.
- **Élevée** : revue approfondie des composants et contrats affectés, scénarios de défaillance, résultats de tests et vérification de l’annulation.
- **Critique** : revue humaine obligatoire des éléments concernés, vérification des protections, des données et du plan de restauration ; appliquer les exigences des propriétaires.

Le rayon d’explosion fixe la barre : un défaut local réversible et une corruption touchant tous les consommateurs n’exigent pas les mêmes preuves. Une description de PR utile couvre tests, risques et annulation ; son absence doit devenir une recommandation concrète. Si un diff ou son contexte manque, qualifier l’analyse de partielle, donner une cote prudente avec notes justifiées et demander les éléments manquants ; ne jamais présenter le résultat comme exhaustif.
