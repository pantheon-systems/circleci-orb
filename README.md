# Pantheon CircleCI Orb

This reposistory contains the source code for Pantheon's CircleCI Orb.





## Usage


### Set up

- Make a GitHub or Bitbucket Repo
- Push Your Site's Code to that repo
- Enable CircleCI integration
- create `.circleci/config`
  - Copy this example
- Make sure you allow orbs
- Set up authentication
  - ssh keys
  - Terminus Token
  - Set TERMINUS_SITE
- Disallowed paths in pantheon.yml

### Examples


### Parameters

`checkout` Set to false if you are are directly calling `checkout` in your `pre-steps` section.

`preserve_commits`????? If this option is checked all commits made on github will be pushed to Pantheon. This option should only be used if you are not building any artifacts to be pushed to Pantheon as part of your CI process (Installing dependencies from Composer, compiling Sass)


## Assumptions and Intended Audience

The initial release of the Pantheon Orb is intended to be most helpful to existing Pantheon customers you have been interested in, but reluctant to adopt continuous integration. This Orb should help you take an existing site on Pantheon and start managing the code on GitHub (or BitBucket) and begin to to introduce additional build steps.

If you already have a mature CI discipline within your team this Orb may not provide significant additional value at this time. If you are starting a fresh site and want a complete Composer-based workflow with CI, then you are better off making a copy of Example Drops 8 Composer or Example WordPress Composer.

### (Mostly) One way code flow





## Related Projects

- Terminus
- Terminus Build Tools
- Example Drops 8 Composer
- Example WordPress Composer




### stuff to fit in above

pushing, force pushing
