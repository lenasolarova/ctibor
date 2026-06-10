---
name: triage-open-prs
description: >-
  Triage all open GitHub PRs across ObsInt Processing team
  repos. Fetches fresh PR data, classifies each PR into
  action buckets (merge, fix CI, stale, review needed,
  close), and outputs a summary with recommendations. Use
  when the user says "triage PRs", "open PRs", "PR status",
  or on a daily scheduled check.
---

# Triage Open PRs

Scan all team GitHub repos for open pull requests, classify
each one, and produce an actionable summary.

## Step 1 — Fetch fresh PR data

The fetcher script lives in the `processing-tools` repo.
Locate it and run it:

```bash
# Find the script — check cloned repo first, fall back to submodule
SCRIPT=""
for candidate in \
    repos/processing-tools/open_mr_pr/github/list_repos_prs.py \
    processing-tools/open_mr_pr/github/list_repos_prs.py; do
  if [ -f "$candidate" ]; then SCRIPT="$candidate"; break; fi
done

if [ -z "$SCRIPT" ]; then
  echo "ERROR: list_repos_prs.py not found" >&2
  exit 1
fi

cd "$(dirname "$SCRIPT")"
python3 list_repos_prs.py
```

This produces three files in the same directory:
- `open-prs.csv` — all PRs as CSV
- `open-prs-konflux.md` — Konflux/Renovate bot PRs
- `open-prs-others.md` — human and other bot PRs

Read all three files after running.

## Step 2 — Classify each PR

For every open PR, assign one action bucket:

| Bucket | Criteria | Recommended action |
|--------|----------|-------------------|
| **MERGE** | CI passing, not draft, ready for merge | Approve and merge (or notify reviewer) |
| **FIX_CI** | CI failing, Konflux/Renovate author | Invoke `/konflux-dep-bumps` to investigate and fix |
| **RETEST** | CI failing but likely infra flake (recent, single failure) | Comment `/retest` on the PR |
| **STALE** | Open >14 days with no activity | Ping author or close |
| **REVIEW** | Human PR, CI passing, awaiting review | Flag for team review |
| **DRAFT** | Marked as draft | Skip — author still working |
| **CLOSE** | Abandoned (>30 days, draft, no activity) | Suggest closing |

### Classification rules

1. **Konflux/Renovate PRs** (`app/red-hat-konflux`, `app/dependabot`):
   - CI passing → **MERGE**
   - CI failing → **FIX_CI**

2. **Bot's own PRs** (`app/obsint-processing-app`, `platex-rehor-bot`):
   - CI passing → **MERGE**
   - CI failing → **FIX_CI**
   - Open >14 days → **STALE**

3. **Human PRs**:
   - Draft → **DRAFT**
   - CI passing → **REVIEW**
   - CI failing, open >14 days → **STALE**
   - CI failing, recent → **FIX_CI** (flag for author)
   - Open >30 days, no recent activity → **CLOSE**

To check last activity on a PR:

```bash
gh pr view <NUMBER> --repo <OWNER/REPO> --json updatedAt --jq '.updatedAt'
```

## Step 3 — Output the triage summary

Present a markdown table grouped by bucket, most actionable
first:

```
## Open PR Triage — <DATE>

**<TOTAL> open PRs across <N> repos**

### Ready to merge (<count>)
| Repo | PR | Title | Author | Age |
...

### CI failures — needs fix (<count>)
| Repo | PR | Title | Author | CI | Age |
...
→ Run `/konflux-dep-bumps` for Konflux PRs in this group.

### Needs review (<count>)
| Repo | PR | Title | Author | Age |
...

### Stale (>14 days) (<count>)
| Repo | PR | Title | Author | Age | Last activity |
...

### Draft (<count>)
(listed for awareness, no action needed)
```

## Step 4 — Suggest next actions

After the summary, list concrete next steps:

1. If there are MERGE-ready PRs: "These <N> PRs have passing CI and can be merged now."
2. If there are FIX_CI Konflux PRs: "Run `/konflux-dep-bumps` to triage the <N> failing Konflux PRs."
3. If there are STALE PRs: "Consider pinging authors or closing these <N> stale PRs."
4. If everything is clean: "All clear — no open PRs need attention."
