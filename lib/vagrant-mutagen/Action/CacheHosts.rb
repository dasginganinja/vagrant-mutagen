module VagrantPlugins
  module Mutagen
    module Action
      class CacheHosts
        include Mutagen

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
        end

        def call(env)
          cacheHostEntries
          @app.call(env)
        end

      end
    end
  end
end
