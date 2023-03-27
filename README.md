[![Docker CI](https://github.com/dargstack/dargstack-example/workflows/CI/badge.svg)](https://github.com/dargstack/dargstack-example/actions?query=workflow%3A%22CI%22)

# DargStack Example

This is just a basic Nuxt app that is served as the main website within the [dargstack-example_stack](https://github.com/dargstack/dargstack-example_stack).


## Table of Contents

1. **[Quickstart](#quickstart)**


## Quickstart

For deployment on a new server, execute the following two commands, followed by `dargstack deploy -p latest`.

```bash
mkdir ~/scripts/ \
    && wget https://raw.githubusercontent.com/dargstack/dargstack/master/src/dargstack -O ~/scripts/dargstack \
    && chmod +x ~/scripts/dargstack \
    && echo 'export PATH="$PATH:$HOME/scripts/"' >> ~/.bashrc \
    && . ~/.bashrc

mkdir -p ~/dargstack/dargstack/dargstack-example_stack/ \
    && cd ~/dargstack/dargstack/dargstack-example_stack/
```

After creating the resources as requested, that's already it!
The example stack should be up and running using the parameters you've set.
