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

You currently only need the `hostname` and a `:private_network` network with a fixed IP address.

    config.vm.network :private_network, ip: "192.168.3.10"
    config.vm.hostname = "www.testing.de"
    config.mutagen.aliases = ["alias.testing.de", "alias2.somedomain.com"]

This IP address and the hostname will be used for the entry in the `/etc/hosts` file.

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

### 0.0.1
* Started with vagrant-hostsupdater 1.1.0
* Changed all references of hostsupdater to mutagen.
* Have not tested anything, but this is pushed up.
