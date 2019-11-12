require "vagrant"

module VagrantPlugins
  module Mutagen
    class Config < Vagrant.plugin("2", :config)
        attr_accessor :id
        attr_accessor :orchestrate

        def initialize
          @orchestrate = false
        end
    end
  end
end
