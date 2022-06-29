# frozen_string_literal: true

require_relative 'base'
require_relative '../options/global'

module RubyTerraform
  module Commands
    # Wraps the +terraform force-unlock+ command which manually unlocks the
    # state for the defined configuration.
    #
    # This will not modify your infrastructure. This command removes the lock on
    # the state for the current workspace. The behavior of this lock is
    # dependent on the backend being used. Local state files cannot be unlocked
    # by another process.
    #
    # For options accepted on construction, see {#initialize}.
    #
    # When executing an instance of {ForceUnlock} via {#execute}, the following
    # options are supported:
    #
    # * +:lock_id+: the lock ID output when attempting an operation that failed
    #   due to a lock; required.
    # * +:directory+: the path to a directory containing terraform
    #   configuration (deprecated in terraform 0.14, removed in terraform 0.15,
    #   use +:chdir+ instead).
    # * +:chdir+: the path of a working directory to switch to before executing
    #   the given subcommand.
    # * +:force+: If +true+, does not ask for input for unlock confirmation;
    #   defaults to +false+.
    #
    # The {#execute} method accepts an optional second parameter which is a map
    # of invocation options. Currently, the only supported option is
    # +:environment+ which is a map of environment variables to expose during
    # invocation of the command.
    #
    # @example Basic Invocation
    #   RubyTerraform::Commands::ForceUnlock.new.execute(
    #     lock_id: '50e844a7-ebb0-fcfd-da85-5cce5bd1ec90')
    #
    class ForceUnlock < Base
      include RubyTerraform::Options::Global

      # @!visibility private
      def subcommands
        %w[force-unlock]
      end

      # @!visibility private
      def options
        %w[-force] + super
      end

      # @!visibility private
      def arguments(parameters)
        [parameters[:lock_id], parameters[:directory]]
      end
    end
  end
end
