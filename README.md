# Pantheon CircleCI Orb

[![CircleCI](https://circleci.com/gh/pantheon-systems/circleci-orb.svg?style=svg)](https://circleci.com/gh/pantheon-systems/circleci-orb)
[![Actively Maintained](https://img.shields.io/badge/Pantheon-Actively_Maintained-yellow?logo=pantheon&color=FFDC28)](https://pantheon.io/docs/oss-support-levels#actively-maintained-support)


This reposistory contains the source code for Pantheon's [CircleCI Orb](https://circleci.com/docs/2.0/orb-intro/).
Orbs are a way of encapsulating sharable CircleCI jobs and commands.

This repository provides a job to push code from GitHub or BitBucket to [Pantheon](https://pantheon.io) through CircleCI.

Use this Orb if you want to progressively introduce continuous integration into a new or pre-existing project on Pantheon.
If you're instead looking to start a new Composer-based site with multiple CI steps pre-configured, please start from our [example-drops-8-composer](https://github.com/pantheon-systems/example-drops-8-composer) or [example-wordpress-composer](https://github.com/pantheon-systems/example-wordpress-composer) repositories.
Those can be copied in one command using the [Terminus Build Tools Plugin](https://github.com/pantheon-systems/terminus-build-tools-plugin).

## Setting Up an Existing Pantheon Site To Use the `push` Job From This Orb

0. First, make sure your Pantheon site has an initialized Live environment. If you are making a brand-new site, only the Dev environment will be present. Make the Test and Live environments because this Orb will copy the database and files from the Live environment to newly created Multidev environment (or the Dev environment when building on the `master` branch).
1. Make a GitHub repo with the code from your Pantheon site.
   * Make a [new repo](https://github.com/new) on GitHub if you do not have one yet.
   * Add the new GitHub repo as a remote to a local clone of your Pantheon site: `git remote add github git@github.com:YOUR_USERNAME/YOUR_REPO.git
   * Push the master branch (the code currently on your Pantheon Dev environment) to the newly created GitHub repo: `git push github master:master`
2. Configure CircleCI for your repository.
   * Sign in to [CircleCI](https://circleci.com/dashboard) and set up the repo for Circle builds.
   * Set up can be done at the URL `https://circleci.com/setup-project/gh/YOUR_USERNAME/YOUR_REPO`
   * In your local checkout of your code, create a file at `.circleci/config.yml`.
   * Copy this example into the `.circleci/config.yml` file.
        ```yml
        version: 2.1
        workflows:
          version: 2
          just_push:
              jobs:
              - pantheon/push
        orbs:
          pantheon: pantheon-systems/pantheon@0.6.0
        ```
   * Commit and push the file to GitHub. CircleCI will build attempt to run the workflow but it will return an error message because the steps below have not yet been completed. Turning failing red builds into passing green builds is part of the joy of CI.
   * Set the "[Allow Uncertified Orbs](https://circleci.com/docs/2.0/orbs-faq/#using-3rd-party-orbs)" option to allow Orbs written by those other than CircleCI to be used within your organization. For GitHub users this can be done at `https://circleci.com/gh/organizations/YOUR_USERNAME_OR_ORGNAME/settings#security`
3. Set up SSH keys and environment variables.
   * Pantheon requires SSH keys for performing git interactions. CircleCI needs a private key that matches a public key connected to your Pantheon account (or another account with access to the Pantheon site in question).
      * Create a new SSH key on your local machine in a tmp directory with `ssh-keygen -m PEM -t rsa -b 4096 -f /tmp/new_key_for_ci -N ''`.
      * Copy  the newly created public key (`cat /tmp/new_key_for_ci.pub | pbcopy`) and [add it to your Pantheon account](https://pantheon.io/docs/ssh-keys/).
        * `pbcopy` is a command installed by default on MacOS systems. If you use a different operating system you may need to copy and paste the SSH key values manually. See the [Pantheon SSH key documentation](https://pantheon.io/docs/ssh-keys/) for more information on SSH key generation.
      * Copy the private key (`cat /tmp/new_key_for_ci | pbcopy`) and add it to your CircleCI configuration by using the "SSH Permissions" settings. Set the hostname as `drush.in` and paste your private key into the text box.
   * Under Environment Variables in your CircleCI settings add a variable for `TERMINUS_SITE` set to the machine name of your Pantheon site. If you don't know the machine name of your site, look at the URL of the Dev or Test environment of the site. For example in the URL for a Dev environment, `https://dev-pantheon-weekly-demo-site.pantheonsite.io/`, the machine name is `pantheon-weekly-demo-site`.
   * [Create a Terminus machine token using the Pantheon Dashboard](https://pantheon.io/docs/machine-tokens/). Add it as another environment variable in CircleCI named `TERMINUS_TOKEN`.
   * Retrigger a build in CircleCI either by pushing a whitespace (or otherwise inocuous) change to your code on GitHub. This time, the build should pass.
4. (Optional) Under "Advanced Settings" in your CircleCI repository settings turn on "Only build pull requests." While not necessary, this setting prevents separate Pantheon Multidev environment from being created for each commit. With this setting on, all created Multidevs will be named by pull request number and subsequent pushes to an open pull request will reuse the same Multidev environment.

### Examples

Here is the simplest possible usage of this orb in a `.circleci/config.yml` file.

```yml
version: 2.1
workflows:
  version: 2
  just_push:
    jobs:
    - pantheon/push
orbs:
  pantheon: pantheon-systems/pantheon@0.5.2
```

Here is an example that compiles Sass in a separate job before pushing to Pantheon.

```yml
version: 2.1
workflows:
  version: 2
  build_deploy_and_test:
    jobs:
      - pantheon/static_tests
      - npmbuild_and_persist
      - pantheon/push:
          # This "requires" section tells CircleCI the order in which
          # jobs must be run.
          requires:
            - npmbuild_and_persist
            - pantheon/static_tests
          # Because the checkout command is called from pre-steps, it should
          # not be run inside the orb-defined steps.
          checkout: false
          pre-steps:
            # Perform a git checkout of the code from GitHub/Bitbucket so that
            # custom commands (the rm below) can alter the code before it is
            # pushed to Pantheon.
            - checkout
            # Attach this dist directory created in npmbuild_and_persist
            # which contains the compiled css.
            - attach_workspace:
                at: .
            # The dist directory that holds the compiled Sass is git ignored.
            # It needs to be committed on Pantheon.
            # Removing this .gitignore file makes it available for committing.
            # Pantheon's Composer examples use a more complicated
            # technique of "cutting" the top level .gitignore
            # file so that lines specifying build artifact directories are removed.
            # https://github.com/pantheon-systems/example-drops-8-composer/blob/670ae310c601dabbb7b35411ff3e08e4b1fac7a3/composer.json#L67
            - run: rm web/themes/custom/default/.gitignore
            # Optional: Run a script to build needed stuff if you are not using IC or if you have further needs.
            - run: ./.ci/build/php
      - pantheon/visual_regression:
          requires:
            - pantheon/push
          filters:
              branches:
                ignore:
                  - master
      - pantheon/behat_tests:
          requires:
            - pantheon/visual_regression
  scheduled_update_check:
    triggers:
      - schedule:
          cron: "0 21 * * *"
          filters:
            branches:
              only:
                - master
    jobs:
      - pantheon/composer_lock_updater
orbs:
  pantheon: pantheon-systems/pantheon@0.2.0
jobs:
  # This job compiles Sass and then saves (persists) the directory
  # containing the compiled css for reuse in the pantheon/push job.
  npmbuild_and_persist:
    docker:
      - image: node:12.16.1
    steps:
      - checkout
      - run:
          name: install npm dependencies in a custom Drupal child theme
          command: cd web/themes/custom/default && yarn install
      - run:
          name: Compile Sass
          command: cd web/themes/custom/default && yarn production && rm -rf web/themes/custom/default/node_modules
      - persist_to_workspace:
          root: .
          paths:
            - web/themes/custom/default
```

### Parameters

Jobs from CircleCI Orbs can take parameters (variables) that alter the behavior of the job.

| parameter name             | type    | default value | required | description                                                                                                                                                                |
|----------------------------|---------|---------------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `checkout`                 | boolean | `true`        | no       | Determines whether a git checkout will be the first command called by the job. Set to false if you have already called "checkout" in the `pre-steps` section.              |
| `clone_content`           | boolean | `true`        | no       | Determines whether or not every build will re-clone content from the environment set in terminus_clone_env. Set to false if cloning the database and files means builds are taking too long.         |
| `env_create_max_time`      | string  | `"10m"`       | no       | The maximum amount of time to wait for Pantheon environment creation (terminus -n build:env:create). This parameter maps to CircleCI's native `no_output_timeout` option." |
| `resource_class`      | string  | `"medium"`       | no       | The [size of the container](https://circleci.com/product/features/resource-classes/) can be increased for memory-intensive build steps or decreased to reduce billing impact. |
| `terminus_clone_env`       | string  | `"live"`      | no       | The source environment from which the database and uploaded files are cloned.                                                                                              |
| `directory_to_push`        | string  | `"."`         | no       | The directory within the repository to push to Pantheon. Use this setting if you have a more complex repo structure that puts your Pantheon root in a deeper directory. For instance, if you are using a monorepo to manage a backend CMS on Pantheon and a decoupled frontend deployed elsewhere, set this param to the name of the directory that holds your `pantheon.yml` file. |
| `set_env_vars`       | boolean  | `true`      | no       | Should this job run a script to set env vars like TERMINUS_ENV? Set to false if you set variables in 'pre-steps'                                                |
| `static_tests_script`| string | `"./.ci/test/static/run"` | no | Script to run static tests. Based on "Example Drops 8 Composer" or "Example Wordpress Composer" repos |
| `vrt_run_script`| string | `"./.ci/test/visual-regression/run"` | no | Script to run visual regression tests. Based on "Example Drops 8 Composer" or "Example Wordpress Composer" repos |
| `behat_initialize_script`| string | `"./.ci/test/behat/initialize"` | no | Script to prepare behat tests. Based on "Example Drops 8 Composer" or "Example Wordpress Composer" repos |
| `behat_run_script`| string | `"./.ci/test/behat/run"` | no | Script to run behat tests. Based on "Example Drops 8 Composer" or "Example Wordpress Composer" repos |
| `behat_clean_script`| string | `"./.ci/test/behat/cleanup"` | no | Script to cleanup behat tests. Based on "Example Drops 8 Composer" or "Example Wordpress Composer" repos |

## Assumptions and Intended Audience

The initial release of the Pantheon Orb is intended to be most helpful to existing Pantheon customers who have been interested in, but reluctant to adopt continuous integration. This Orb should help you take an existing site on Pantheon and start managing the code on GitHub (or BitBucket) and begin to introduce additional build steps like the compilation of Sass or the running of tests.

If you already have a mature CI discipline within your team this Orb may not provide significant additional value at this time. If you are starting a fresh site and want a complete Composer-based workflow with CI, then you are better off making a copy of [example-Drops-8-composer](https://github.com/pantheon-systems/example-drops-8-composer) or [example-wordpress-composer](https://github.com/pantheon-systems/example-wordpress-composer).

## Related Projects

- [Terminus](https://pantheon.io/docs/terminus/) is the Pantheon command line tool. This Orb uses Terminus in order to do things like authenticate with Pantheon. As is mentioned in the set up steps above, you will need to supply a `TERMINUS_TOKEN` environment variable to CircleCI for authentication to work.
- [Terminus Build Tools](https://github.com/pantheon-systems/terminus-build-tools-plugin) is a plugin for Terminus that encapsulates many Continuous Integration tasks. It relies on you setting the machine name of your site as a `TERMINUS_SITE` environment variable in CircleCI for certain commands to function.
- [Example Drops 8 Composer](https://github.com/pantheon-systems/example-drops-8-composer) is an example repository that shows a Composer-based Drupal 8 workflow that goes from GitHub to CircleCI to Pantheon. [It may soon incorporate this Orb](https://github.com/pantheon-systems/example-drops-8-composer/pull/245).
- [Example WordPress Composer](https://github.com/pantheon-systems/example-wordpress-composer) is the WordPress twin to Example Drops 8 Composer.

## Support

This project is under active development and you may find bugs or have questions. Please use [the issue queue for this project](https://github.com/pantheon-systems/circleci-orb/issues).
