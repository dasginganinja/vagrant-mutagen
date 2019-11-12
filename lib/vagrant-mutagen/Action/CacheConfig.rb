module VagrantPlugins
  module Mutagen
    module Action
      class CacheConfig
        include Mutagen

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
        end

        def call(env)
          if mutagen_enabled
            cacheConfigEntries
          end
          @app.call(env)
        end

      end
    end
  end
end
