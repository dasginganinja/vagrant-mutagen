require "vagrant"

module VagrantPlugins
  module Mutagen
    class Config < Vagrant.plugin("2", :config)
        attr_accessor :id
        attr_accessor :orchestrate
        attr_accessor :project_file

        def initialize
          @orchestrate = UNSET_VALUE
          @project_file = UNSET_VALUE
        end

        def finalize!
          @orchestrate = false if @orchestrate == UNSET_VALUE
          @project_file = "mutagen.yml" if @project_file == UNSET_VALUE
        end
    end
  end
end
