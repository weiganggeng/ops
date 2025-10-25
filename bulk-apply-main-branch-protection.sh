#!/usr/bin/env bash
set -euo pipefail

# Applies branch protection to main for a list of repos (no status-check gating).
# Requires: GitHub CLI (gh) and admin perms: `gh auth login`

ORG="lambdal"
REPOS=(
  lks
  mk8s-cluster-validation
  mk8s-continuous-validation
  terraform-mk8s-infra
  ll-sdk-go
  cluster-components
  # cluster-api-provider-lambda
  #cluster-manager-inventories
  node-problem-detector
  helm-intelliflash
  helm-exascaler
  cluster-manager
  #ll-internal-sdk-go

  cluster-api-provider-lambda-metal
  gpud
  lambda-cloud-controller-manager
  local-path-provisioner
  argocd-cluster-manager
  helm-draino
  fasttrack-sdk-go
)

for r in "${REPOS[@]}"; do
  echo "Protecting $ORG/$r:main"

  gh api \
    -X PUT \
    -H "Accept: application/vnd.github+json" \
    "/repos/$ORG/$r/branches/main/protection" \
    --input - <<'JSON'
{
  "required_status_checks": null,                // no required checks / no "up-to-date" gating
  "enforce_admins": true,                        // enforce for admins
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,               // new commits dismiss approvals
    "require_code_owner_reviews": true,          // require CODEOWNERS (set false if you don't want this)
    "required_approving_review_count": 1,        // set to 2 if desired
    "require_last_push_approval": true           // blocks self-merge/last-pusher merge
  },
  "restrictions": null,                          // no push restrictions (teams/users/apps)
  "required_linear_history": true,               // linear history (no merge commits) - optional
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true       // all comments must be resolved
}
JSON

done

echo "✅ Branch protection applied to main on ${#REPOS[@]} repositories."
