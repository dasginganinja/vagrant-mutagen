require "vagrant"

module VagrantPlugins
  module Mutagen
    class Config < Vagrant.plugin("2", :config)
        attr_accessor :id
    end
  end
end
