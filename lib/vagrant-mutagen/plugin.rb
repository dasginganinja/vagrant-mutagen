require "vagrant-mutagen/Action/UpdateConfig"
require "vagrant-mutagen/Action/CacheConfig"
require "vagrant-mutagen/Action/RemoveConfig"
require "vagrant-mutagen/Action/StartOrchestration"
require "vagrant-mutagen/Action/TerminateOrchestration"

module VagrantPlugins
  module Mutagen
    class Plugin < Vagrant.plugin('2')
      name 'Mutagen'
      description <<-DESC
        This plugin manages the ~/.ssh/config file for the host machine. An entry is
        created for the hostname attribute in the vm.config.
      DESC

      config(:mutagen) do
        require_relative 'config'
        Config
      end

      action_hook(:mutagen, :machine_action_up) do |hook|
        hook.after(Vagrant::Action::Builtin::WaitForCommunicator, Action::StartOrchestration)
        hook.after(Vagrant::Action::Builtin::WaitForCommunicator, Action::UpdateConfig)
      end

      action_hook(:mutagen, :machine_action_provision) do |hook|
        hook.before(Vagrant::Action::Builtin::Provision, Action::UpdateConfig)
        hook.before(Vagrant::Action::Builtin::Provision, Action::StartOrchestration)
      end

      action_hook(:mutagen, :machine_action_halt) do |hook|
        hook.before(Vagrant::Action::Builtin::GracefulHalt, Action::TerminateOrchestration)
      end

      action_hook(:mutagen, :machine_action_suspend) do |hook|
        hook.prepend(Action::TerminateOrchestration)
      end

      action_hook(:mutagen, :machine_action_destroy) do |hook|
        hook.before(Vagrant::Action::Builtin::GracefulHalt, Action::CacheConfig)
        hook.before(Vagrant::Action::Builtin::GracefulHalt, Action::TerminateOrchestration)
        hook.after(Vagrant::Action::Builtin::GracefulHalt, Action::RemoveConfig)
      end

      action_hook(:mutagen, :machine_action_reload) do |hook|
        hook.before(Vagrant::Action::Builtin::GracefulHalt, Action::TerminateOrchestration)
        hook.after(Vagrant::Action::Builtin::WaitForCommunicator, Action::StartOrchestration)
        hook.after(Vagrant::Action::Builtin::WaitForCommunicator, Action::UpdateConfig)
      end

      action_hook(:mutagen, :machine_action_resume) do |hook|
        hook.after(Vagrant::Action::Builtin::WaitForCommunicator, Action::StartOrchestration)
        hook.after(Vagrant::Action::Builtin::WaitForCommunicator, Action::UpdateConfig)
      end

      command(:mutagen) do
        require_relative 'command'
        Command
      end
    end
  end
end
