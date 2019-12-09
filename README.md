# Vagrant::Mutagen

[![Gem Version](https://badge.fury.io/rb/vagrant-mutagen.svg)](https://badge.fury.io/rb/vagrant-mutagen)
[![Gem](https://img.shields.io/gem/dt/vagrant-mutagen.svg)](https://rubygems.org/gems/vagrant-mutagen)
[![Gem](https://img.shields.io/gem/dtv/vagrant-mutagen.svg)](https://rubygems.org/gems/vagrant-mutagen)

This plugin adds an entry to your `~/.ssh/config` file on the host system.

On **up**, **resume** and **reload** commands, it tries to add the information, if it does not already exist in your config file. 
On **halt**, **destroy**, and **suspend**, those entries will be removed again.


## Installation

    $ vagrant plugin install vagrant-mutagen

Uninstall it with:

    $ vagrant plugin uninstall vagrant-mutagen

Update the plugin with:

    $ vagrant plugin update vagrant-mutagen

## Usage

You need to set `orchestrate` and `config.vm.hostname`.

    config.mutagen.orchestrate = true

This hostname will be used for the entry in the `~/.ssh/config` file.

Orchestration also requires a `mutagen.yml` file configured for your project.

### Example Project Orchestration Config (`mutagen.yml`)

As an example starting point you can use the following for a Drupal project:
```
sync:
  defaults:
    mode: "two-way-resolved"
    ignore:
      vcs: false
      paths:
        - /.idea/
        - /vendor/**/.git/
        - contrib/**/.git/
        - node_modules/
        - /web/sites/**/files/
    symlink:
      mode: "portable"
    watch:
      mode: "portable"
    permissions:
      defaultFileMode: 0644
      defaultDirectoryMode: 0755
  app:
    alpha: "your-vm.hostname:/srv/www/app/"
    beta: "./app/"
```

## Installing development version

If you would like to install vagrant-mutagen on the development version perform the following:

```
git clone https://github.com/dasginganinja/vagrant-mutagen
cd vagrant-mutagen
git checkout develop
gem build vagrant-mutagen.gemspec
vagrant plugin install vagrant-mutagen-*.gem
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request on the `develop` branch


## Versions

### 0.1.2
* Issues with multiple VMs arose due to outdated SSH config. SSH config is now regenerated each `vagrant up`.

### 0.1.1
* Added mutagen.yml example

### 0.1.0
* Added config to enable orchestration.
* Added new actions to start and terminate orchestration.
* Hooked new actions into vagrant lifecycle events.
* Refactored vagrant-hostsupdater hosts commands for config.

### 0.0.1
* Started with vagrant-hostsupdater 1.1.0
* Changed all references of hostsupdater to mutagen.
* Have not tested anything, but this is pushed up.
