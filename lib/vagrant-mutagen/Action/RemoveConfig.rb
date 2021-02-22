module VagrantPlugins
  module Mutagen
    module Action
      class RemoveConfig
        include Mutagen

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          machine_action = env[:machine_action]
          if mutagen_enabled
            @ui.info "[vagrant-mutagen] Checking for removing SSH config entry"
            removeConfigEntries
          end
          @app.call(env)
        end

      end
    end
  end
end
