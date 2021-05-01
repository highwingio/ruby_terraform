# frozen_string_literal: true

require 'spec_helper'

describe RubyTerraform::Commands::Destroy do
  let(:command) { described_class.new(binary: 'terraform') }

  before do
    RubyTerraform.configure do |config|
      config.binary = 'path/to/binary'
      config.logger = Logger.new(StringIO.new)
    end
  end

  after do
    RubyTerraform.reset!
  end

  command = 'destroy'
  directory = Faker::File.dir

  it_behaves_like(
    'a command with an argument',
    [command, :directory]
  )

  it_behaves_like(
    'a command without a binary supplied',
    [command, described_class, directory]
  )

  it_behaves_like(
    'a command with an argument', [command, :directory]
  )

  it_behaves_like(
    'a command without a binary supplied',
    [command, described_class, directory]
  )

  it_behaves_like(
    'a command with an option',
    [command, :backup, directory]
  )

  it_behaves_like(
    'a command that can disable backup',
    [command, directory]
  )

  it_behaves_like(
    'a command with a flag',
    [command, :compact_warnings, directory]
  )

  it_behaves_like(
    'a command with a boolean option',
    [command, :lock, directory]
  )

  it_behaves_like(
    'a command with an option',
    [command, :lock_timeout, directory]
  )

  it_behaves_like(
    'a command with a boolean option',
    [command, :input, directory]
  )

  it_behaves_like(
    'a command with a boolean option',
    [command, :auto_approve, directory]
  )

  it_behaves_like(
    'a command with a flag',
    [command, :no_color, directory]
  )

  it_behaves_like(
    'a command with an option',
    [command, :parallelism, directory]
  )

  it_behaves_like(
    'a command with a boolean option',
    [command, :refresh, directory]
  )
  it_behaves_like(
    'a command with an option',
    [command, :state, directory]
  )
  it_behaves_like(
    'a command with an option',
    [command, :state_out, directory]
  )
  it_behaves_like(
    'a command with an array option',
    [command, :targets, directory]
  )
  it_behaves_like(
    'a command that accepts vars', [command, directory]
  )
  it_behaves_like(
    'a command with an array option',
    [command, :var_files, directory]
  )
  it_behaves_like(
    'a command with global options',
    [command, directory]
  )
end
