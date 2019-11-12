require_relative "../Mutagen"
module VagrantPlugins
  module Mutagen
    module Action
      class UpdateConfig
        include Mutagen


        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          if mutagen_enabled
            @ui.info "[vagrant-mutagen] Checking for SSH config entries"
            addConfigEntries()
          end
          @app.call(env)
        end

      end
    end
  end
end