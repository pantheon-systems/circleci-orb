# Release Process for this Orb

*Please read this entire document before making any new releases of the Pantheon CircleCI Orb.*

This Orb is released to the [CircleCI Orb Registry](https://circleci.com/orbs/registry/orb/pantheon-systems/pantheon). Although releases can be made by directly invoking the `circleci` CLI program they only should be made via tags on this repo made through the [GitHub Releases](https://github.com/pantheon-systems/circleci-orb/releases) user interface to ensure that each release includes release notes on GitHub and to reduce the possibility of errors.

Every tag pushed to GitHub (through the releases interface or otherwise) triggers [a workflow in Circle](https://github.com/pantheon-systems/circleci-orb/blob/655b6b4a1af5f52dc51b64e5909ea5127ea9ca17/.circleci/config.yml#L19) that makes the new release. Yes, a different Circle Orb is used to publish the release of our Circle Orb.

The exact tag name used in Git is the exact version name used on Circle so double and triple check that you are making a tag of the correct name given Semantic Version rules. See below for more details. There is [a pending issue](https://github.com/pantheon-systems/circleci-orb/issues/20) on this repo for considering a more robust release process that does not require the releaser to declare an exact tag name but instead know only whether it is major, minor, or patch.

# Guidance on how to use Semantic Versioning.


Examples of changes that would trigger a major version release.

* **What should trigger a major release?**
  * [Semver.org says "when you make incompatible API changes"](https://semver.org/).
  * Removing or renaming a parameter, command, or job. These three concepts are what consumers of the Orb use directly. Removing or renaming one of these elements would break a consuming configuration so only take this action for very good reason. A preferrable option is to rename and deprecate. If, for some reason the `push` job changed to `build`, it would be best to first add a `build` job that is identical to `push` and then add notices in `push` saying that it was deprecated and announcing when it would no longer be supported.
  * Adding a **required** parameter to a command or job would break consumers that do not use that parameter. As such, adding a new required parameter or converting an existing parameter from optional to required should be avoided when possible. It is greatly preferrable to add an optional parameter with a widely sensible default value. Even changing a default value of an existing parameter can be done without triggering a major version if users of the Orb do not perceive the change as "breaking" their workflow (which is a subjective judgement in many cases).
  * Significant new additions of functionality that fundamentally change how the Orb is intended to be used, even if backwards compatibility is retained.
* **What should trigger a minor release?**
  * [Semver.org says "when you add functionality in a backwards-compatible manner"](https://semver.org/).
  * Adding jobs, commands, and optional parameters that do not fundamentally change the intended usage of the entire Orb should trigger minor releases.
* **What should trigger a patch release?**
  * [Semver.org says "when you make backwards-compatible bug fixes."](https://semver.org/).
    * A bug is a mismatch between expectations and reality. For the purposes of releases in this 