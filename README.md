[![Docker CI](https://github.com/dargstack/dargstack-example/workflows/CI/badge.svg)](https://github.com/dargstack/dargstack-example/actions?query=workflow%3A%22CI%22)

# DargStack Example

This is just a basic Nuxt app that is served as the main website within the [dargstack-example_stack](https://github.com/dargstack/dargstack-example_stack).


## Table of Contents

1. **[Quickstart](#quickstart)**


## Quickstart

For deployment on a new server, e.g. a Debian machine at [Hetzner Cloud](https://www.hetzner.com/cloud), execute the following steps:

1. optional: create the server using your ssh public key
    1. `ssh` into it as root
    1. use [hetzner-start.sh](https://gist.github.com/dargmuesli/645a4d51ab1806ebfb3329fb05637318) for minimal setup (update installation, `git` installation, user creation, hostname setting)
    1. `exit` the current ssh session and reconnect using your just created user account
    1. use [docker-debian-amd64-start.sh](https://gist.github.com/dargmuesli/58073a79a71f97e6bdd60d6cb93f207c) to install Docker
    1. setup DNS for your server, e.g. using [Cloudflare](https://www.cloudflare.com/)

1. install **dargstack** on your server as explained under [dargstack/dargstack#installation-example](https://github.com/dargstack/dargstack#installation-example)
1. create a project directory like `dargstack/<namespace>`:
    ```bash
    mkdir -p ~/dargstack/dargstack \
        && cd ~/dargstack/dargstack
    ```
1. clone your repository like `dargstack/dargstack-example_stack`:
    ```bash
    git clone https://github.com/dargstack/dargstack-example_stack \
        && cd dargstack-example_stack
    ```
1. run `dargstack deploy -p latest`, follow the instructions and you're done 🎉
    1. if you encounter [docker/for-linux issue #1199](https://github.com/docker/for-linux/issues/1199), run `sudo apt install apparmor` and reboot
    1. if ssl certificates do not work even after waiting some time, run `dargstack redeploy -p latest`
