# Coter le risque d’une pull request

Ce skill guide un agent pour analyser le changement d’une PR GitHub, calculer une cote pondérée et déposer un commentaire unique lié au commit analysé. L’auteur du changement ne participe jamais au calcul.

## Installation et utilisation

Copier ce dossier complet à un emplacement de skills reconnu par l’outil utilisé, ou lui fournir directement `SKILL.md`. Conserver les liens relatifs et les fichiers d’aide. Aucun environnement d’exécution particulier n’est requis pour lire les instructions. Le script demande Bash 4 ou ultérieur et les utilitaires usuels `head` et `cat` ; une publication réelle demande aussi `gh` authentifié avec accès en lecture à la PR et en écriture à ses commentaires. Aucune dépendance de traitement JSON supplémentaire n’est nécessaire.

Demande type : « Analyse le risque de la PR 42 du dépôt fictif `atelier-imaginaire/produit-fictif`, puis publie la cote justifiée au commit de tête. » Pour préparer seulement le résultat, préciser « sans publication ».

L’agent suit [SKILL.md](SKILL.md), lit [criteria.md](criteria.md), remplit l’unique [gabarit provisoire](comment-template.md) et utilise le script de publication. Le gabarit temporaire sera remplacé après validation humaine ; modifier sa définition uniquement dans `comment-template.md`. Les [exemples](examples/faible.md) sont des sorties remplies, pas d’autres définitions du gabarit.

```bash
# Le fichier commentaire.md contient le corps rempli, à partir du marqueur.
bash scripts/publish-pr-risk-comment.sh 42 commentaire.md --repo atelier-imaginaire/produit-fictif --dry-run
# Publication réelle, seulement dans un usage autorisé avec accès au réseau.
bash scripts/publish-pr-risk-comment.sh 42 commentaire.md --repo atelier-imaginaire/produit-fictif --commit "$SHA_COMPLET"
```

Une URL de PR peut remplacer le numéro et fournit alors le dépôt. Pour un numéro sans `--repo`, le script résout le dépôt courant lors d’une publication réelle. En simulation, il ne résout rien et n’appelle jamais `gh`.

## Échelle et critères

| Niveau calculé | Score | Orientation |
|---|---|---|
| 🟢 Faible | 0–24 | Documents, textes, fonctions internes ou isolées par un indicateur |
| 🟡 Modérée | 25–49 | Produit ordinaire, cache, mise à jour automatique, invites système |
| 🟠 Élevée | 50–74 | Code à plus haut risque, interactions et conséquences étendues |
| 🔴 Critique | 75–100 | Attention humaine obligatoire ou impact difficilement réversible |

La grille pondère zones sensibles (25 %), migrations et données (20 %), taille et étendue (15 %), couverture de tests (15 %), API publique et contrats (10 %), dépendances (10 %) et réversibilité (5 %). Chaque note va de 0 à 5 ; le score est la somme de `note / 5 × poids`, arrondie à l’entier le plus proche.

Les seuils donnent le niveau initial. Des planchers imposent au moins Modérée pour le produit ordinaire et les comportements de cache, mise à jour automatique ou invites système. Authentification, facturation, CI et publication, installeurs, chemins déclarés sensibles et migrations irréversibles imposent ici Critique et une attention humaine. Le second regard peut encore rehausser d’un cran, sans dépasser Critique. Le score reste inchangé et la justification explique tout rehaussement. Voir les règles et nuances dans `criteria.md`.

## Publication idempotente et actualité

Le script cherche `<!-- pr-risk-rating:v1 -->` dans les commentaires d’issue de la PR, sur toutes les pages. Il effectue un PATCH du commentaire existant, ou un POST si aucun n’existe. En présence de doublons anciens, il actualise celui ayant le plus grand identifiant, sans supprimer les autres. Sérialiser les exécutions pour une même PR : deux créations simultanées ne sont pas protégées par un verrou côté serveur.

Le corps est transmis intégralement depuis le fichier. Il doit suivre `comment-template.md` et commencer par le marqueur, sans le bandeau PROVISOIRE. Le script vérifie cette première ligne ; la conformité du reste du gabarit relève de l’agent. Il ne crée jamais d’avis d’approbation.

La cote vise le SHA du pied de page. `--commit` refuse l’écriture si la tête a déjà changé ; il est recommandé pour toute publication réelle. L’agent vérifie aussi la base et la tête autour de l’analyse et après publication. De nouveaux commits imposent une nouvelle analyse et la mise à jour du même commentaire. Le script ne déclenche pas lui-même ces analyses et une course reste possible entre vérification et publication.

## Vérifications locales sans réseau

Depuis la racine du dossier :

```bash
bash -n scripts/publish-pr-risk-comment.sh
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck scripts/publish-pr-risk-comment.sh
fi
# Création simulée, même si la variable était déjà définie ailleurs.
PR_RISK_COMMENT_ID= bash scripts/publish-pr-risk-comment.sh 42 examples/faible.md --repo atelier-imaginaire/produit-fictif --dry-run
# Mise à jour simulée d’un identifiant fictif, sans recherche distante.
PR_RISK_COMMENT_ID=7654321 bash scripts/publish-pr-risk-comment.sh 42 examples/moderee.md --repo atelier-imaginaire/produit-fictif --dry-run
```

Ces deux simulations affichent respectivement `create` et `update` avec le corps fourni ; la seconde indique aussi `7654321`. Elles ne prouvent ni les droits GitHub ni le comportement d’une publication réelle. Pour les fichiers livrés, la syntaxe Bash, les deux simulations et la conformité des exemples au gabarit et aux calculs ont été vérifiées sans réseau ; `shellcheck` n’était pas disponible. Un substitut local de `gh` a aussi permis de vérifier les chemins POST et PATCH, le parcours paginé demandé, la sélection de l’identifiant le plus grand et les refus en cas de commit périmé ou d’échec de lecture. Aucun appel réel à GitHub n’a été effectué.

## Inspiration et adaptation

Ce skill s’inspire du billet [« How the Claude Code team does code review », claude.dev Blog, 15 octobre 2026](https://claude.dev/blog/solving-code-review-at-anthropic/). Il en reprend les idées suivantes :

- Évaluer le changement, pas son auteur.
- Reprendre trois niveaux : documents, textes, fonctions internes et ajouts derrière un indicateur au niveau faible ; produit ordinaire, cache, mise à jour automatique et invites système au niveau modéré ; code à plus haut risque au niveau élevé. Ajouter Critique pour les chemins exigeant toujours une personne ou deux personnes et les impacts difficilement réversibles.
- Classer une première fois, puis demander si ce changement précis justifie un niveau supérieur, notamment pour un chemin sensible ou un workflow CI.
- Conserver une attention humaine pour les chemins déclarés sensibles par les propriétaires et tous les fichiers de workflow CI ; inclure aussi authentification, facturation, CI et publication, installeurs, cités dans la section d’adoption du billet.
- Examiner tests, risque et annulation, que devrait couvrir le gabarit de PR.
- Proportionner l’effort de revue au risque : le rayon d’explosion fixe la barre.
- Attacher la cote à un commit précis et la refaire après de nouveaux commits.
- Ne jamais substituer une cote d’agent à l’avis humain requis.

Les poids, notes, seuils numériques, planchers précis, quatrième niveau et mécanisme de commentaire sont des choix de ce skill. Ils adaptent ces idées au besoin de coter un diff ; ils ne prétendent pas reproduire le fonctionnement interne décrit dans le billet.

## Limites et licence

L’analyse statique ne prouve ni la sécurité ni l’absence de régression. Des tests présents ne sont pas forcément exécutés ; une description de PR ne prouve pas leur réussite. Un contexte incomplet doit être visible dans la cote et ses recommandations. La cote est une aide à la revue, jamais une autorisation de fusion ni un avis humain. N’inclure ni secret ni donnée personnelle dans le commentaire.

Les exemples, chemins, dépôts et SHA sont strictement fictifs. Le code et les documents sont distribués sous [licence MIT](LICENCE), dans une traduction française.
