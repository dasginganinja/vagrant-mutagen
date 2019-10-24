require "vagrant"

module VagrantPlugins
  module Mutagen
    class Config < Vagrant.plugin("2", :config)
        attr_accessor :id
        attr_accessor :enable # Consider calling this orchestrated or make this internal with an orchestrated option.

        def initialize
          @enable = false
        end
    end
  end
end
