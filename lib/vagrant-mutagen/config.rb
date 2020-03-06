require "vagrant"

module VagrantPlugins
  module Mutagen
    class Config < Vagrant.plugin("2", :config)
        attr_accessor :id
        attr_accessor :orchestrate

        def initialize
          @orchestrate = UNSET_VALUE
        end

        def finalize!
          @orchestrate = false if @orchestrate == UNSET_VALUE
        end
    end
  end
end
