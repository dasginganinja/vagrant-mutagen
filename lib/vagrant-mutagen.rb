require "vagrant-mutagen/version"
require "vagrant-mutagen/plugin"

module VagrantPlugins
  module Mutagen
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end

