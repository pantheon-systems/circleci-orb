# Release Process for this Orb

*Please read this entire document before making any new releases of the Pantheon CircleCI orb.*

This orb is released to the [CircleCI Orb Registry](https://circleci.com/orbs/registry/orb/pantheon-systems/pantheon). Although releases can be made by directly invoking the `circleci` CLI program, they only should be made via tags on this repo. Use the [GitHub Releases](https://github.com/pantheon-systems/circleci-orb/releases) user interface to ensure that each release includes release notes on GitHub and to reduce the possibility of errors.

Every tag pushed to GitHub (through the releases interface or otherwise) triggers [a workflow in Circle](https://github.com/pantheon-systems/circleci-orb/blob/655b6b4a1af5f52dc51b64e5909ea5127ea9ca17/.circleci/config.yml#L19) that makes the new release to the registry. And yes, a different Circle orb is used to publish the release of our Circle orb.

The exact tag name used in Git is the exact version name used as the version name in the CircleCI Orb Registry so double and triple check that you are making a tag of the correct name given Semantic Version rules. See below for more details. There is [a pending issue](https://github.com/pantheon-systems/circleci-orb/issues/20) on this repo for considering a more robust release process that does not require the releaser to declare an exact tag name but instead know only whether it is major, minor, or patch.

## Guidance on how to use Semantic Versioning.

Examples of changes that would trigger a major version release.

* **What should trigger a major release?**
  * [Semver.org says "when you make incompatible API changes"](https://semver.org/).
  * Removing or renaming a parameter, command, or job. These three concepts are what consumers of the orb use directly. Removing or renaming one of these elements would break a consuming configuration so only take this action for very good reason. A preferrable option is to rename and deprecate. If, for some reason the `push` job changed to `build`, it would be best to first add a `build` job that is identical to `push` and then add notices in `push` saying that it was deprecated and announcing when it would no longer be supported.
  * Adding a **required** parameter to a command or job would break consumers that do not use that parameter. As such, adding a new required parameter or converting an existing parameter from optional to required should be avoided when possible. It is greatly preferrable to add an optional parameter with a widely sensible default value. Even changing a default value of an existing parameter can be done without triggering a major version if users of the orb do not perceive the change as "breaking" their workflow (which is a subjective judgement in many cases).
  * Significant new additions of functionality that fundamentally change how the orb is intended to be used, even if backwards compatibility is retained.
* **What should trigger a minor release?**
  * [Semver.org says "when you add functionality in a backwards-compatible manner"](https://semver.org/).
  * Adding jobs, commands, and optional parameters that do not fundamentally change the intended usage of the entire orb should trigger minor releases.
* **What should trigger a patch release?**
  * [Semver.org says "when you make backwards-compatible bug fixes."](https://semver.org/).
    * A bug is a mismatch between expectations and reality.
    * Documentation additions and fixes.
    * Adding example usages.

## How do we know that a release is safe?

In order to know that it is safe to tag the master branch for release, the orb needs to be tested. To do that, demonstration repositories on GitHub configured to use the orb switch to development versions.

Currently this is a manual process. Steve Persch has used a mix of three repositories:

* [stevector/wordpress-orb-demo](https://github.com/stevector/wordpress-orb-demo) is a simple WordPress site that uses the push job after a separate job compiles Sass in a child theme.
* [stevector/stevector-composer](https://github.com/stevector/stevector-composer) is a composer-based wordpress repository.
* [stevector/nerdologues-d8](https://github.com/stevector/nerdologues-d8) is a composer-based Drupal 8 repository.

Here are example PRs that have manually set the above repos to use development releases of the orb:

* [Using a dev branch](https://github.com/stevector/nerdologues-d8/pull/347/files)
* [Using an orb version made specifically for a single git commit](https://github.com/stevector/wordpress-orb-demo/pull/5/files)

If recent changes to the orb change behavior specific to the master branch then one or more of these repositories needs to temporarily merge the usage of the dev orb into their master branch.

There is [an open issue to further standardize and automate this process](https://github.com/pantheon-systems/circleci-orb/issues/2) and remove the dependency on Steve’s personal projects.

## Writing Release Notes
