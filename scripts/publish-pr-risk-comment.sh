#!/usr/bin/env bash
# Publier le corps rempli à partir de comment-template.md sans le réécrire.
set -euo pipefail

usage() {
    cat <<'AIDE'
Usage : bash scripts/publish-pr-risk-comment.sh PR FICHIER [--repo DEPOT] [--commit SHA] [--dry-run]
PR : numéro positif ou URL https://github.com/proprietaire/depot/pull/123.
DEPOT : proprietaire/depot ; sinon, dépôt de l’URL ou dépôt courant.
SHA : SHA complet attendu ; refuser l’écriture si la tête a changé.
--dry-run : aucune commande réseau ; afficher le corps et create ou update.
PR_RISK_COMMENT_ID : identifiant positif simulé, uniquement avec --dry-run.
Le corps doit être rempli depuis comment-template.md, sans son bandeau.
AIDE
}

erreur() { printf 'Erreur : %s\n' "$*" >&2; exit 1; }

if [[ ${1:-} == --help || ${1:-} == -h ]]; then usage; exit 0; fi
[[ $# -ge 2 ]] || { usage >&2; exit 1; }
pr=$1
corps=$2
shift 2
depot=''
commit=''
simulation=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --repo|--commit)
            [[ $# -ge 2 && -n $2 ]] || erreur "Valeur manquante pour $1."
            if [[ $1 == --repo ]]; then depot=$2; else commit=$2; fi
            shift 2 ;;
        --dry-run) simulation=true; shift ;;
        *) erreur "Option inconnue : $1." ;;
    esac
done

if [[ $pr =~ ^https://github\.com/([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)/pull/([1-9][0-9]*)/?$ ]]; then
    depot_url=${BASH_REMATCH[1]}
    pr=${BASH_REMATCH[2]}
    [[ -z $depot || $depot == "$depot_url" ]] || erreur 'Le dépôt ne correspond pas à l’URL.'
    depot=$depot_url
fi
[[ $pr =~ ^[1-9][0-9]*$ ]] || erreur 'Numéro ou URL de PR invalide.'
[[ -z $depot || $depot =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || erreur 'Dépôt invalide.'
[[ -z $commit || $commit =~ ^[a-fA-F0-9]{40}$ ]] || erreur 'Le SHA attendu doit contenir 40 caractères hexadécimaux.'
[[ -f $corps && -r $corps && -s $corps ]] || erreur 'Le fichier de commentaire est absent, vide ou illisible.'
marqueur='<!-- pr-risk-rating:v1 -->'
[[ $(head -n 1 -- "$corps") == "$marqueur" ]] || erreur 'Le corps doit commencer par le marqueur du gabarit, sans bandeau.'

identifiant=''
if $simulation; then
    identifiant=${PR_RISK_COMMENT_ID:-}
    [[ -z $identifiant || $identifiant =~ ^[1-9][0-9]*$ ]] || erreur 'Identifiant simulé invalide.'
else
    command -v gh >/dev/null 2>&1 || erreur 'La commande gh est requise pour publier.'
    if [[ -z $depot ]]; then
        depot=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
    fi
    # Parcourir toutes les pages ; retenir le plus grand identifiant en cas de doublon ancien.
    identifiants=$(gh api --paginate "repos/$depot/issues/$pr/comments" \
        --jq '.[] | select((.body // "") | contains("<!-- pr-risk-rating:v1 -->")) | .id')
    for candidat in $identifiants; do
        [[ $candidat =~ ^[1-9][0-9]*$ ]] || erreur 'Identifiant de commentaire inattendu.'
        if [[ -z $identifiant ]] || (( candidat > identifiant )); then identifiant=$candidat; fi
    done
    if [[ -n $commit ]]; then
        tete=$(gh pr view "$pr" --repo "$depot" --json headRefOid --jq .headRefOid)
        [[ ${tete,,} == "${commit,,}" ]] || erreur 'La tête de PR a changé : refaire la cote avant publication.'
    fi
fi

action=create
[[ -z $identifiant ]] || action=update
if $simulation; then
    printf 'Simulation sans réseau — action prévue : %s' "$action"
    [[ -z $identifiant ]] || printf ' ; identifiant : %s' "$identifiant"
    printf ' ; PR : %s ; dépôt : %s\n' "$pr" "${depot:-courant (non résolu)}"
    [[ -z $commit ]] || printf 'Commit attendu : %s (non vérifié en simulation)\n' "$commit"
    cat -- "$corps"
elif [[ $action == update ]]; then
    gh api --method PATCH "repos/$depot/issues/comments/$identifiant" --field "body=@$corps" --silent
    printf 'Commentaire actualisé : %s.\n' "$identifiant"
else
    gh api --method POST "repos/$depot/issues/$pr/comments" --field "body=@$corps" --silent
    printf 'Commentaire créé sur la PR %s.\n' "$pr"
fi
