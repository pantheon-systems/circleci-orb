---
contract_version: 2
kind: tool                          # a CircleCI orb (pantheon-systems/pantheon) that customers' CircleCI pipelines run
service: null                       # doesn't apply

trigger: tag                        # a tag push runs CircleCI workflow 'publish' -> orb version named after the tag
merged_implies_deployed: false      # merging to master publishes only a dev:master orb version (when CI works); customers pin semver versions
other_paths_to_prod:
  - "manual publish by a CircleCI org admin: circleci orb publish src/@orb.yml pantheon-systems/pantheon@X.Y.Z (how 0.7.1 was published; .circleci/release_process.md)"
  - "every branch push publishes dev:<branch> (dev versions expire after 90 days; customers shouldn't use them)"

pipeline:
  system: other                     # CircleCI, .circleci/config.yml with circleci/orb-tools@8.5.0
  workflow: ".circleci/config.yml"
  jobs_in_order: ["publish-dev (every branch)", "publish (tags only)"]
  typical_minutes: null             # TODO(verify-on-deploy): no successful run to time
  minutes_by_change: {}
  watch: "CircleCI project gh/pantheon-systems/circleci-orb, workflow 'publish' for the tag; then the orb registry"
  concurrency_group: null
  cancel_in_progress: false
  blocked_by_waiting_run: null
  approval_gate: null

repo_properties:
  observed_at: 2026-11-10
  trust_level: TL4
  ccb_status: in-ccb
  owner: developer-experience
  repo_type: library

gating_checks:                      # `gh api repos/pantheon-systems/circleci-orb/rules/branches/master`, 2026-11-10
  required: ["Wiz IaC Scanner", "Wiz Vulnerability Scanner", "Wiz Data Scanner"]   # org TL4 only
  approvals: {required: 1, code_owner: true, last_push_approval: false, strict_up_to_date: false, merge_queue: true}   # repo ruleset 'Protect master branch' adds a squash merge queue and dismisses stale approvals on push
  run_but_not_required: ["ci/circleci: publish-dev"]
  conditional: []

environments: []

artifact:
  image: null
  tag_scheme: semver                # git tags without v (0.7.0); orb versions are named exactly after the tag
  tag_mutable: false                # orb registry versions are immutable; git tags unprotected by convention
  retention: "semver orb versions are permanent; dev:* versions expire after 90 days"
  version_signal: tag
  tag_to_sha: "git rev-list -n1 <tag> (but registry 0.7.1 has no git tag; it matches master's src/@orb.yml)"

release:
  mechanism: "create a GitHub release/tag on master named X.Y.Z; CircleCI 'publish' runs orb-tools/publish to pantheon-systems/pantheon@X.Y.Z"
  published_to: ["CircleCI orb registry: pantheon-systems/pantheon (verified 2026-11-10: latest 0.7.1, 2023-11-08; no 0.7.0)"]
  never: "publish a breaking change as a patch/minor: consumers may pin @0.7 or @volatile and get it immediately"

consumers:                          # registry statistics, 2026-11-10
  - {repo: "customer CircleCI projects", pin: ".circleci/config.yml orbs: pantheon: pantheon-systems/pantheon@<version>", version: null, owner: customers, bumped_by: customers}
  # last 30 days: 4443 builds, 24 projects, 11 organizations. No pantheon-systems repo uses it (code search).

deployed_when:
  - "circleci orb source pantheon-systems/pantheon@X.Y.Z is identical to src/@orb.yml at the tag"

health:
  soak_minutes: null                # no runtime; health is consumer pipelines, which we can't see
  baseline: "registry statistics: ~4400 builds / 24 projects / 11 orgs per 30 days (2026-11-10)"
  checks:
    - name: published
      kind: command
      run: "curl -s -X POST https://circleci.com/graphql-unstable -H 'Content-Type: application/json' -d '{\"query\":\"{orb(name:\\\"pantheon-systems/pantheon\\\"){versions(count:3){version createdAt}}}\"}'"
      healthy: "lists X.Y.Z"        # verified: returns 0.7.1 first
    - name: usage didn't collapse
      kind: command
      run: "same endpoint with statistics{last30DaysBuildCount last30DaysProjectCount last30DaysOrganizationCount}"
      healthy: "not far below the baseline above"   # coarse: a 30-day window
  known_baseline_errors: []
  dashboards: []
  alerts: []

rollback:
  options:
    - when: always
      kind: re-release-previous     # orb versions can't be deleted or changed: publish the previous source as the next patch version
      steps: "git checkout <last good tag> -- src/@orb.yml on a branch, merge, tag X.Y.(Z+1) (or circleci orb publish by an org admin while CI is broken)"
      time_to_rollback_minutes: null   # TODO(verify-on-deploy)
  not_restored: ["consumers that pinned the exact bad version keep it until they change their config"]
  one_way_changes: ["a published orb version is permanent"]
  currently_blocked: "CircleCI checkout fails for this project (git clone access error, pipeline 144 on master, 2026-03-27), so a tag can't publish; manual publish by an org admin is the only path"
  last_exercised: null
  capture_before_merge: "the latest registry version (published check above)"
  who_can: ["CircleCI org admins for the pantheon-systems namespace"]   # TODO(owner): who in DevX is one
  verify: "registry lists the new patch version; circleci orb source shows the old content"

escalation:
  slack: "#ask-hosting"
  owner_team: developer-experience
  paged: false                      # inferred

preflight:
  - "gh auth status"
  - "circleci CLI token with org-admin rights on the pantheon-systems namespace (publish/rollback only)"

automation_blockers:
  - blocker: "the CircleCI pipeline fails at checkout (since at least 2026-03-27), so the tag-to-publish path doesn't work"
    clears_when: "the project's checkout key is fixed and one tag publishes successfully"
  - blocker: "publishing (and rollback) needs a CircleCI org admin; no agent has that"
    clears_when: "owner names who can publish, or publishing moves to a scoped token in a working pipeline"
  - blocker: "no health signal beyond 30-day registry usage counts"
    clears_when: "accepted for a customer-facing CI orb, or integration tests (issue #2) run against a demo project"

verified:
  at: null
  by: null
  change: null
  running_digest: null              # doesn't apply
---

# Deployment

This repo is the **Pantheon CircleCI orb** (`pantheon-systems/pantheon`), which customers use in their own CircleCI pipelines to push code to Pantheon. Nothing runs at Pantheon. A "release" is a new orb version in the CircleCI registry; customers pick it up when their config references it.

## How a change reaches production

1. **PR → merge to `master`.** TL4 org ruleset: 1 approval from a code owner (`@pantheon-systems/developer-experience`). Only the Wiz checks are required. The repo ruleset adds a squash merge queue and dismisses stale approvals on push.
2. **Dev version.** CircleCI workflow `publish-dev` publishes `pantheon-systems/pantheon@dev:<branch>` on every push.
3. **Release.** Create a GitHub release on `master` with tag `X.Y.Z` (no `v`; follow the semver guidance in [.circleci/release_process.md](.circleci/release_process.md)). CircleCI workflow `publish` (tags only) publishes `pantheon-systems/pantheon@X.Y.Z`. A manual alternative is `circleci orb publish src/@orb.yml pantheon-systems/pantheon@X.Y.Z` by a CircleCI org admin.
4. **Consumers** reference a version in their `.circleci/config.yml`. In the last 30 days the registry counted about 4,400 builds from 24 projects in 11 organizations. No pantheon-systems repo uses it.

**Current state (2026-11-10):**

- **The CircleCI pipeline is broken.** The latest pipeline (144, `master`, 2026-03-27) failed at "Checkout code" with a `git clone` access error. A tag pushed today wouldn't publish.
- The registry's latest version is **0.7.1** (2023-11-08). It has no git tag; it was published by hand. Its content equals `master`'s `src/@orb.yml`; later commits only changed docs and repo metadata.
- Git tag **0.7.0** exists but **0.7.0 isn't in the registry**, while the README's examples use `pantheon-systems/pantheon@0.7.0`.
- The orb's default executor uses `quay.io/pantheon-public/build-tools-ci:8.x-php8.1`, an image line Pantheon has stopped updating.

## How to confirm it deployed

```sh
curl -s -X POST https://circleci.com/graphql-unstable -H 'Content-Type: application/json' \
  -d '{"query":"{orb(name:\"pantheon-systems/pantheon\"){versions(count:3){version createdAt}}}"}'
circleci orb source pantheon-systems/pantheon@X.Y.Z | diff - src/@orb.yml   # empty = published content matches (verified for 0.7.1 vs master)
```

## How to confirm it's healthy

We can't see customer pipelines. The only signal is the registry's 30-day usage statistics (query above with `statistics{last30DaysBuildCount last30DaysProjectCount last30DaysOrganizationCount}`), plus issues on this repo and reports in `#ask-hosting`. Before releasing, test with a demo project pointed at the `dev:` version (`.circleci/release_process.md`, "Testing Releases").

## Rollback

Orb versions can't be deleted or edited. To roll back, publish the previous content as the next patch version:

1. On a branch: `git checkout <last good tag> -- src/@orb.yml`, merge, and tag `X.Y.(Z+1)`.
2. While CircleCI is broken, a CircleCI org admin publishes it by hand: `circleci orb publish src/@orb.yml pantheon-systems/pantheon@X.Y.(Z+1)`.
3. Consumers pinned to the exact bad version keep it until they change their config; tell them through the issue queue or a release note.

Verify: the registry lists the new version, and `circleci orb source` shows the restored content.

## Escalation

- Owner: `@pantheon-systems/developer-experience`. Ask in `#ask-hosting`. Not paged.
- Customer reports arrive through [this repo's issues](https://github.com/pantheon-systems/circleci-orb/issues).

## Suggested pipeline changes

- Fix the CircleCI project's checkout access, then publish one release through the pipeline.
- Publish 0.7.0's intended content as a version that exists, or change the README examples to `@0.7.1`.
- Upgrade from `circleci/orb-tools@8.5.0` to a current orb-tools release.
- Move the default executor off the `build-tools-ci` image.
