# rbenv

Update list of Rubies
```shell
cd ~/.rbenv/plugins/ruby-build;git pull
```

Commands
```shell
# list latest stable versions:
rbenv install -l

# list all local versions:
rbenv install -L

# install a Ruby version:
rbenv install 3.1.7

rbenv local 3.1.7
```

## Nuke and clean
```
rbenv clean
dnf remove rbenv
rm -rf ~/.rbenv
rm -rf ~/.gem
```
