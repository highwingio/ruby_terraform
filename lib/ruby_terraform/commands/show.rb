# frozen_string_literal: true

require_relative 'base'
require_relative '../options/global'

module RubyTerraform
  module Commands
    # Wraps the +terraform show+ command which reads and outputs a Terraform
    # state or plan file in a human-readable form. If no path is specified, the
    # current state will be shown.
    #
    # For options accepted on construction, see {#initialize}.
    #
    # When executing an instance of {Show} via {#execute}, the following
    # options are supported:
    #
    # * +:path+: the path to a state file or plan to show.
    # * +:chdir+: the path of a working directory to switch to before executing
    #   the given subcommand.
    # * +:no_color+: whether or not the output from the command should be in
    #   color; defaults to +false+.
    # * +:json+: if +true+, outputs the Terraform plan or state in a
    #   machine-readable form; defaults to +false+.
    #
    # The {#execute} method accepts an optional second parameter which is a map
    # of invocation options. Currently, the only supported option is
    # +:environment+ which is a map of environment variables to expose during
    # invocation of the command.
    #
    # @example Basic Invocation
    #   RubyTerraform::Commands::Show.new.execute
    #
    class Show < Base
      include RubyTerraform::Options::Global

      # @!visibility private
      def subcommands
        %w[show]
      end

      # @!visibility private
      def options
        %w[
          -json
          -no-color
        ] + super
      end

      # @!visibility private
      def arguments(parameters)
        [parameters[:path]]
      end
    end
  end
end
