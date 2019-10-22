module VagrantPlugins
  module Mutagen
    module Action
      class RemoveHosts
        include Mutagen

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          machine_action = env[:machine_action]
          if machine_action != :destroy || !@machine.id
            if machine_action != :suspend
              if machine_action != :halt
                @ui.info "[vagrant-mutagen] Removing SSH config entry"
                removeHostEntries
              end
            end
          end
          @app.call(env)
        end

      end
    end
  end
end
