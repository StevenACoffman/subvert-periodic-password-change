# active-directory-subvert-mandatory-password-change

Change the Active Directory password for a username using Docker 25 times in a row, and then back to original password.
Because mandatory password reset policies are stupid, and scripting this from a mac is a pain.

## Requirements

* [Docker](https://www.docker.com/get-docker)

## Usage

The container can be run using the following command:

    docker run --interactive --rm --tty stevenacoffman/active-directory-subvert-mandatory-password-change USERNAME DOMAIN

This will cause the password for `USERNAME` to be changed in the `DOMAIN` Active
Directory domain. Frequently, the internal domain is office.share.org, so you might try that.

### Required values

* Docker flags: `-i` or `--interactive` is required, otherwise your password
  can't be entered securely.
* Input parameters: Both the `USERNAME` and `DOMAIN` values are required.

### Note bene

+ You probably want to build this from scratch and run locally, because it's *your* password, and you don't need to trust me.
+ You probably want to be connected via ethernet and turn off any Active directory polling service like wifi or outlook, because you'll get locked out.

### Credit Where Credit is Due

This is a fork of Sasha Gerrand's [docker-smbpasswd](https://github.com/sgerrand/docker-smbpasswd) modified for my own subversive purposes.