# frozen_string_literal: true

require_relative 'base'
require_relative '../options/global'

module RubyTerraform
  module Commands
    # Wraps the +terraform workspace new+ command which creates a new workspace.
    #
    # For options accepted on construction, see {#initialize}.
    #
    # When executing an instance of {WorkspaceNew} via {#execute}, the
    # following options are supported:
    #
    # * +:name+: the name of the workspace to create; required.
    # * +:directory+: the path to a directory containing terraform configuration
    #   (deprecated in terraform 0.14, removed in terraform 0.15, use +:chdir+
    #   instead).
    # * +:chdir+: the path of a working directory to switch to before executing
    #   the given subcommand.
    # * +:lock+: when +true+, locks the state file when locking is supported;
    #   when +false+, does not lock the state file; defaults to +true+.
    # * +:lock_timeout+: the duration to retry a state lock; defaults to +"0s"+.
    # * +:state+: the path to a state file to copy into the new workspace.
    #
    # The {#execute} method accepts an optional second parameter which is a map
    # of invocation options. Currently, the only supported option is
    # +:environment+ which is a map of environment variables to expose during
    # invocation of the command.
    #
    # @example Basic Invocation
    #   RubyTerraform::Commands::WorkspaceNew.new.execute(
    #     name: 'example')
    #
    class WorkspaceNew < Base
      include RubyTerraform::Options::Global

      # @!visibility private
      def subcommands
        %w[workspace new]
      end

      # @!visibility private
      def options
        %w[
          -lock
          -lock-timeout
          -state
        ] + super
      end

      # @!visibility private
      def arguments(parameters)
        [parameters[:name], parameters[:directory]]
      end
    end
  end
end
