# frozen_string_literal: true

require_relative 'base'
require_relative '../options/global'

module RubyTerraform
  module Commands
    # Wraps the +terraform destroy+ command which destroys terraform managed
    # infrastructure.
    #
    # For options accepted on construction, see {#initialize}.
    #
    # When executing an instance of {Destroy} via {#execute}, the following
    # options are supported:
    #
    # * +:directory+: the path to a directory containing terraform
    #   configuration (deprecated in terraform 0.14, removed in terraform 0.15,
    #   use +:chdir+ instead).
    # * +:chdir+: the path of a working directory to switch to before executing
    #   the given subcommand.
    # * +:auto_approve+: if +true+, skips interactive approval before
    #   destroying; defaults to +false+.
    # * +:backup+: (legacy) the path to backup the existing state file before
    #   modifying; defaults to the +:state_out+ path with +".backup"+ extension;
    #   set +:no_backup+ to +true+ to skip backups entirely.
    # * +:compact_warnings+: when +true+, if terraform produces any warnings
    #   that are not accompanied by errors, they are shown in a more compact
    #   form that includes only the summary messages; defaults to +false+.
    # * +:input+: when +false+, will not ask for input for variables not
    #   directly set; defaults to +true+.
    # * +:lock+: when +true+, locks the state file when locking is supported;
    #   when +false+, does not lock the state file; defaults to +true+.
    # * +:lock_timeout+: the duration to retry a state lock; defaults to +"0s"+.
    # * +:no_backup+: when +true+, no backup file will be written; defaults to
    #   +false+.
    # * +:no_color+: whether or not the output from the command should be in
    #   color; defaults to +false+.
    # * +:parallelism+: the number of parallel resource operations; defaults to
    #   +10+.
    # * +:refresh+: when +true+, updates state prior to checking for
    #   differences; when +false+ uses locally available state; defaults to
    #   +true+.
    # * +:state+: (legacy) the path to the state file from which to read state
    #   and in which to store state (unless +:state_out+ is specified); defaults
    #   to +"terraform.tfstate"+.
    # * +:state_out+: (legacy) the path to write state to that is different than
    #   +:state+; this can be used to preserve the old state.
    # * +:target+: the address of a resource to target; if both +:target+ and
    #   +:targets+ are provided, all targets will be passed to terraform.
    # * +:targets+: an array of resource addresses to target; if both +:target+
    #   and +:targets+ are provided, all targets will be passed to terraform.
    # * +:vars+: a map of variables to be passed to the terraform configuration.
    # * +:var_file+: the path to a terraform var file; if both +:var_file+ and
    #   +:var_files+ are provided, all var files will be passed to terraform.
    # * +:var_files+: an array of paths to terraform var files; if both
    #   +:var_file+ and +:var_files+ are provided, all var files will be passed
    #   to terraform.
    #
    # The {#execute} method accepts an optional second parameter which is a map
    # of invocation options. Currently, the only supported option is
    # +:environment+ which is a map of environment variables to expose during
    # invocation of the command.
    #
    # @example Basic Invocation
    #   RubyTerraform::Commands::Destroy.new.execute(
    #     directory: 'infra/networking',
    #     vars: {
    #       region: 'eu-central'
    #     })
    #
    class Destroy < Base
      include RubyTerraform::Options::Global

      # @!visibility private
      def subcommands
        %w[destroy]
      end

      # rubocop:disable Metrics/MethodLength

      # @!visibility private
      def options
        %w[
          -auto-approve
          -backup
          -compact-warnings
          -lock
          -lock-timeout
          -input
          -no-color
          -parallelism
          -refresh
          -state
          -state-out
          -target
          -var
          -var-file
        ] + super
      end

      # rubocop:enable Metrics/MethodLength

      # @!visibility private
      def arguments(parameters)
        [parameters[:directory]]
      end

      # @!visibility private
      def parameter_defaults(_parameters)
        { vars: {}, var_files: [], targets: [] }
      end

      # @!visibility private
      def parameter_overrides(parameters)
        { backup: parameters[:no_backup] ? '-' : parameters[:backup] }
      end
    end
  end
end
