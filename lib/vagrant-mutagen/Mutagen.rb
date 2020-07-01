#TODO: remove before commit, just used for testing with .to_yaml function
require 'yaml'
module VagrantPlugins
  module Mutagen
    module Mutagen
      DISCARD_STDOUT = Vagrant::Util::Platform.windows? ? '>nul'  : '>/dev/null'
      DISCARD_STDERR = Vagrant::Util::Platform.windows? ? '2>nul' : '2>/dev/null'

      if ENV['VAGRANT_MUTAGEN_SSH_CONFIG_PATH']
        @@ssh_user_config_path = ENV['VAGRANT_MUTAGEN_SSH_CONFIG_PATH']
      else
        @@ssh_user_config_path = '~/.ssh/config'
      end
      @@ssh_user_config_path = File.expand_path(@@ssh_user_config_path)

      def addConfigEntries
        # Prepare some needed variables
        uuid = @machine.id
        name = @machine.name
        hostname = @machine.config.vm.hostname
        # New Config for ~/.ssh/config
        newconfig = ''

        # Read contents of SSH config file
        file = File.open(@@ssh_user_config_path, "rb")
        configContents = file.read
        # Check for existing entry for hostname in config
        entryPattern = configEntryPattern(hostname, name, uuid)
        if configContents.match(/#{entryPattern}/)
          @ui.info "[vagrant-mutagen]   updating SSH Config entry for: #{hostname}"
          removeConfigEntries
        else
          @ui.info "[vagrant-mutagen]   adding entry to SSH config for: #{hostname}"
        end

        # Get SSH config from Vagrant
        newconfig = createConfigEntry(hostname, name, uuid)
        # Append vagrant ssh config to end of file
        addToSSHConfig(newconfig)
      end

      def addToSSHConfig(content)
        return if content.length == 0

        @ui.info "[vagrant-mutagen] Writing the following config to (#@@ssh_user_config_path)"
        @ui.info content
        if !File.writable_real?(@@ssh_user_config_path)
          @ui.info "[vagrant-mutagen] This operation requires administrative access. You may " +
                       "skip it by manually adding equivalent entries to the config file."
          if !sudo(%Q(sh -c 'echo "#{content}" >> #@@ssh_user_config_path'))
            @ui.error "[vagrant-mutagen] Failed to add config, could not use sudo"
          end
        elsif Vagrant::Util::Platform.windows?
          require 'tmpdir'
          uuid = @machine.id || @machine.config.mutagen.id
          tmpPath = File.join(Dir.tmpdir, 'hosts-' + uuid + '.cmd')
          File.open(tmpPath, "w") do |tmpFile|
            cmd_content = content.lines.map {|line| ">>\"#{@@ssh_user_config_path}\" echo #{line}" }.join
            tmpFile.puts(cmd_content)
          end
          sudo(tmpPath)
          #[TODO] sudo を実行するのを待たずにファイルが削除されるのか、delete すると cmd が実行されない
          # File.delete(tmpPath)
        else
          content = "\n" + content + "\n"
          hostsFile = File.open(@@ssh_user_config_path, "a")
          hostsFile.write(content)
          hostsFile.close()
        end
      end

      # Create a regular expression that will match the vagrant-mutagen signature
      def configEntryPattern(hostname, name, uuid = self.uuid)
        hashedId = Digest::MD5.hexdigest(uuid)
        Regexp.new("^# VAGRANT: #{hashedId}.*$\nHost #{hostname}.*$")
      end

      def createConfigEntry(hostname, name, uuid = self.uuid)
        # Get the SSH config from Vagrant
        sshconfig = `vagrant ssh-config --host #{hostname}`
        # Trim Whitespace from end
        sshconfig = sshconfig.gsub /^$\n/, ''
        sshconfig = sshconfig.chomp
        # Return the entry
        %Q(#{signature(name, uuid)}\n#{sshconfig}\n#{signature(name, uuid)})
      end

      def cacheConfigEntries
        @machine.config.mutagen.id = @machine.id
      end

      def removeConfigEntries
        if !@machine.id and !@machine.config.mutagen.id
          @ui.info "[vagrant-mutagen] No machine id, nothing removed from #@@ssh_user_config_path"
          return
        end
        file = File.open(@@ssh_user_config_path, "rb")
        configContents = file.read
        uuid = @machine.id || @machine.config.mutagen.id
        hashedId = Digest::MD5.hexdigest(uuid)
        if configContents.match(/#{hashedId}/)
          removeFromConfig
        end
      end

      def removeFromConfig(options = {})
        uuid = @machine.id || @machine.config.mutagen.id
        hashedId = Digest::MD5.hexdigest(uuid)
        if !File.writable_real?(@@ssh_user_config_path) || Vagrant::Util::Platform.windows?
          if !sudo(%Q(sed -i -e '/# VAGRANT: #{hashedId}/,/# VAGRANT: #{hashedId}/d' #@@ssh_user_config_path))
            @ui.error "[vagrant-mutagen] Failed to remove config, could not use sudo"
          end
        else
          hosts = ""
          pair_started = false
          pair_ended = false
          File.open(@@ssh_user_config_path).each do |line|
            # Reset
            if pair_started == true && pair_ended == true
              pair_started = pair_ended = false
            end
            if line.match(/#{hashedId}/)
              if pair_started == true
                pair_ended = true
              end
              pair_started = true
            end
            hosts << line unless pair_started
          end
          hosts.strip!
          hostsFile = File.open(@@ssh_user_config_path, "w")
          hostsFile.write(hosts)
          hostsFile.close()
        end
      end

      def signature(name, uuid = self.uuid)
        hashedId = Digest::MD5.hexdigest(uuid)
        %Q(# VAGRANT: #{hashedId} (#{name}) / #{uuid})
      end

      def sudo(command)
        return if !command
        if Vagrant::Util::Platform.windows?
          require 'win32ole'
          args = command.split(" ")
          command = args.shift
          sh = WIN32OLE.new('Shell.Application')
          sh.ShellExecute(command, args.join(" "), '', 'runas', 0)
        else
          return system("sudo #{command}")
        end
      end

      def orchestration_enabled()
        return @machine.config.mutagen.orchestrate == true
      end

      def mutagen_enabled()
        return orchestration_enabled()
      end

      def startOrchestration()
        daemonCommand = "mutagen daemon start"
        projectStartedCommand = "mutagen project list #{DISCARD_STDOUT} #{DISCARD_STDERR}"
        projectStartCommand = "mutagen project start"
        projectStatusCommand = "mutagen project list"
        if !system(daemonCommand)
          @ui.error "[vagrant-mutagen] Failed to start mutagen daemon"
        end
        if !system(projectStartedCommand) # mutagen project list returns 1 on error when no project is started
          @ui.info "[vagrant-mutagen] Starting mutagen project orchestration (config: /mutagen.yml)"
          if !system(projectStartCommand)
            @ui.error "[vagrant-mutagen] Failed to start mutagen project (see error above)"
          end
        end
        system(projectStatusCommand) # show project status to indicate if there are conflicts
      end

      def terminateOrchestration()
        projectStartedCommand = "mutagen project list #{DISCARD_STDOUT} #{DISCARD_STDERR}"
        projectTerminateCommand = "mutagen project terminate"
        projectStatusCommand = "mutagen project list #{DISCARD_STDERR}"
        if system(projectStartedCommand) # mutagen project list returns 1 on error when no project is started
          @ui.info "[vagrant-mutagen] Stopping mutagen project orchestration"
          if !system(projectTerminateCommand)
            @ui.error "[vagrant-mutagen] Failed to stop mutagen project (see error above)"
          end
        end
        system(projectStatusCommand)
      end

    end
  end
end
