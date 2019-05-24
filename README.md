# Pantheon CircleCI Orb

This reposistory contains the source code for Pantheon's [CircleCI Orb](https://circleci.com/docs/2.0/orb-intro/).
Orbs are a way of encapsulating sharable CircleCI jobs and commands.

This repository provides a job to push code from GitHub or BitBucket to [Pantheon](https://pantheon.io) through CircleCI.

Use this Orb if you want to progressively introduce continuous integration into a new or pre-existing project on Pantheon.
If you're instead looking to start a new Composer-based site with multiple CI steps pre-configured, please start from our [example-drops-8-composer](https://github.com/pantheon-systems/example-drops-8-composer) or [example-wordpress-composer](https://github.com/pantheon-systems/example-wordpress-composer) repositories.
Those can be copied in one command using the [Terminus Build Tools Plugin](https://github.com/pantheon-systems/terminus-build-tools-plugin).

## Setting Up an Existing Pantheon Site To Use the `push` Job From This Orb

1. Make a GitHub repo with the code from your Pantheon site.
   * First make a [new repo](https://github.com/new).
   * Add the new GitHub repo as a remote to a local clone of your Pantheon site: `git remote add github git@github.com:YOUR_USERNAME/YOUR_REPO.git`
   * Push the master branch (the code currently on your Pantheon Dev environment) to the newly created GitHub repo: `git push github master:master`
2. Configure CircleCI for your repository.
   * Sign in to [CircleCI](https://circleci.com/dashboard) and set up the repo for Circle builds.
   * In your local checkout of your code, create a file at `.circleci/config.yml`.
   * Copy this example into the `config.yml` file.
        ```yml
        version: 2.1
        workflows:
          version: 2
          just_push:
              jobs:
              - pantheon/push
        orbs:
        pantheon: pantheon-systems/pantheon@0.0.1
        ```
   * Commit and push the file to GitHub. CircleCI will build attempt to run workflow but it will return an error message because the steps below have not yet been completed. Turning failing red builds into passing green builds is part of the joy of CI.
   * Until this Orb is released as a 1.0.0, you will need to set the "[Allow Uncertified Orbs](https://circleci.com/docs/2.0/orbs-faq/#using-3rd-party-orbs)" option.
3. Set up SSH keys and environment variables.
   * Pantheon requires SSH keys for performing git interactions. CircleCI needs a private key that matches a public key connected to your Pantheon account (or another account with access to the Pantheon site in question).
      * Create a new ssh key with `ssh-keygen -m PEM -t rsa -b 4096 -f /tmp/new_key_for_ci -N ''`.
      * Copy  the newly created public key (`cat /tmp/new_key_for_ci.pub | pbcopy`) and [add it to your Pantheon account](https://pantheon.io/docs/ssh-keys/).
      * Copy the private key (`cat /tmp/new_key_for_ci | pbcopy`) and add it to your CircleCI configuration by using the "SSH Permissions" settings. Set the hostname as "drush.in" and paste your private key into the text box.
   * Under Environment Variables in your CircleCI settings add a variable for `TERMINUS_SITE` set to the machine name of your Pantheon site.
   * [Create a Terminus machine token using the Pantheon Dashboard](https://pantheon.io/docs/machine-tokens/). Add it as another environment variable in CircleCI named `TERMINUS_TOKEN`.
   * Retrigger a build in CircleCI either by pushing a whitespace (or otherwise inocuous) change. This build should pass.
4. (Optional) Under "Advanced Settings" in your CircleCI repository settings turn on "Only build pull requests." While not necessary, this setting prevents separate Pantheon Multidev environment from being created for each commit. With this setting on, all created multidevs will be named by pull request number and subsequent pushes to an open pull request will reuse the same Multidev environment.

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
  pantheon: pantheon-systems/pantheon@0.0.1
```

Here is an example of that includes calling `composer install` before pushing to
Pantheon.

```yml
      version: 2.1
      workflows:
        version: 2
        composer_install_and_push:
          pre-steps:
              - checkout
              # Use --no-dev so that testing dependencies like phpunit are not
              # pushed to Pantheon.
              - run: composer -n install --optimize-autoloader --ignore-platform-reqs --no-dev
              # prepare-for-pantheon is a command copied from
              # https://github.com/pantheon-systems/example-drops-8-composer/blob/master/scripts/composer/ScriptHandler.php#L50
              # It cuts the .gitignore file so that directories like Composer's
              # vendor directory are no longer ignored and can be committed.
              # It also removes .git directories that may have been brought down
              # with dependencies that would cause them to be committed as
              # submodules (which Pantheon does not support)
              - run: composer prepare-for-pantheon
          # Because checkout is called in the pre-steps it should not be called
          # again in the Orb-defined steps.
          checkout: false
          jobs:
            - pantheon/push
      orbs:
        pantheon: pantheon-systems/pantheon@0.0.1
```

### Parameters

Jobs from CircleCI Orbs can take parameters (variables) that alter the behavior of the job. At this time the `push` job takes only one parameter.

| parameter name | type    | default value | required | description                                                                                                                                                |
|----------------|---------|---------------|----------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| checkout       | boolean | true          | no       | Determines whether a git checkout will be the first command called by the job. Set to false if you have already called "checkout" in a `pre-step` section. |  

## Assumptions and Intended Audience

The initial release of the Pantheon Orb is intended to be most helpful to existing Pantheon customers who have been interested in, but reluctant to adopt continuous integration. This Orb should help you take an existing site on Pantheon and start managing the code on GitHub (or BitBucket) and begin to introduce additional build steps like the compilation of Sass or the running of tests.

If you already have a mature CI discipline within your team this Orb may not provide significant additional value at this time. If you are starting a fresh site and want a complete Composer-based workflow with CI, then you are better off making a copy of [example-Drops-8-composer](https://github.com/pantheon-systems/example-drops-8-composer) or [example-wordpress-composer](https://github.com/pantheon-systems/example-wordpress-composer).

## Related Projects

- [Terminus](https://pantheon.io/docs/terminus/) is the Pantheon command line tool. This Orb uses Terminus in order to do things like authenticate with Pantheon. As is mentioned in the set up steps above, you will need to supply a `TERMINUS_TOKEN` environment variable to CircleCI for authentication to work.
- [Terminus Build Tools](https://github.com/pantheon-systems/terminus-build-tools-plugin) is a plugin for Terminus that encapsulates many Continuous Integration tasks. It relies you setting the machine name of your site as a `TERMINUS_SITE` environment variable in CircleCI for certain commands to function.
- [Example Drops 8 Composer](https://github.com/pantheon-systems/example-drops-8-composer) is an example repository that shows a Composer-based Drupal 8 workflow flowing from GitHub to CircleCI to Pantheon. [It may soon incorporate this Orb](https://github.com/pantheon-systems/example-drops-8-composer/pull/245).
- [Example WordPress Composer](https://github.com/pantheon-systems/example-wordpress-composer) is the WordPress twin to Example Drops 8 Composer.

## Support

This project is under active development and you may find bugs or have questions. Please use [the issue queue for this project](https://github.com/pantheon-systems/circleci-orb/issues).
