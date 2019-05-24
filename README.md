# Pantheon CircleCI Orb

This reposistory contains the source code for Pantheon's CircleCI Orb. Orbs are a way of encapsulating sharable CircleCI jobs and commands.

This repository provides a job to push code from GitHub or BitBucket to Pantheon through CircleCI.

Use this Orb if you want to progressively introduce Continuous Integration into a new or pre-existing project on Pantheon. If you're instead looking to start a new Composer-based site with multiple CI steps pre-configured, please start from our Example-Drops-8-Composer or Example-WordPress-Composer repositories. Those can be copied in one command using the Terminus Build Tools Plugin.

## Usage

The simplest usage of this Orb requires adding a `.circleci/config.yml` file to your repository on GitHub. CircleCI can run a workflow of jobs (build steps) on every commit pushed or on every pull request.

```
version: 2.1
workflows:
  version: 2
  just_push:
    jobs:
      - pantheon/push
orbs:
  pantheon: pantheon-systems/pantheon@dev
```

### Set up

1. Make a GitHub or Bitbucket Repo
   * Push Your Site's Code to that repo
2. Enable CircleCI integration
   * create `.circleci/config`
   * Copy this example
   *  Make sure you allow orbs
3. Set up authentication and environment variables.
   * ssh keys
   * Terminus Token
   * Set TERMINUS_SITE
4. (Optional) Disallowed paths in pantheon.yml
5. (Optional) Only build pull requests


### Parameters

`checkout` Set to false if you are are directly calling `checkout` in your `pre-steps` section.

`preserve_commits`????? If this option is checked all commits made on github will be pushed to Pantheon. This option should only be used if you are not building any artifacts to be pushed to Pantheon as part of your CI process (Installing dependencies from Composer, compiling Sass)


### Examples


## Assumptions and Intended Audience

The initial release of the Pantheon Orb is intended to be most helpful to existing Pantheon customers you have been interested in, but reluctant to adopt continuous integration. This Orb should help you take an existing site on Pantheon and start managing the code on GitHub (or BitBucket) and begin to to introduce additional build steps.

If you already have a mature CI discipline within your team this Orb may not provide significant additional value at this time. If you are starting a fresh site and want a complete Composer-based workflow with CI, then you are better off making a copy of Example Drops 8 Composer or Example WordPress Composer.

### (Mostly) One way code flow





## Related Projects

- [Terminus](https://pantheon.io/docs/terminus/) is the Pantheon command line tool. This Orb uses Terminus in order to do things like authenticate with Pantheon. As is mentioned in the set up steps above, you will need to supply a `TERMINUS_TOKEN` environment variable to CircleCI for authentication to work.
- [Terminus Build Tools](https://github.com/pantheon-systems/terminus-build-tools-plugin) is a plugin for Terminus that encapsulates many Continuous Integration tasks. It relies you setting the machine name of your site as a `TERMINUS_SITE` environment variable in CircleCI for certain commands to function.
- [Example Drops 8 Composer](https://github.com/pantheon-systems/example-drops-8-composer) is an example repository created in 2016 that show a Composer-based Drupal 8 workflow flowing from GitHub to CircleCI to Pantheon. It will soon incorporate this Orb.
- [Example WordPress Composer](https://github.com/pantheon-systems/example-wordpress-composer) is the WordPress twin to Example Drops 8 Composer.




### stuff to fit in above

pushing, force pushing
