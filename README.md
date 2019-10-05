# Dargstack Example

For deployment on a new server, execute the following commands, followed by `dargstack deploy -p latest`.

```bash
mkdir ~/scripts/ \
    && wget https://raw.githubusercontent.com/dargmuesli/dargstack/master/dargstack -O ~/scripts/dargstack \
    && chmod +x ~/scripts/dargstack \
    && echo 'export PATH="$PATH:$HOME/scripts/"' >> ~/.bashrc \
    && . ~/.bashrc

mkdir -p ~/dargstack/dargmuesli/dargstack-example_stack/ \
    && cd ~/dargstack/dargmuesli/dargstack-example_stack/
```