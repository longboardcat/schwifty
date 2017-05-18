require 'spec_helper'
require 'fileutils'

RSpec.configure do |rspec|
  rspec.mock_with :rspec do |mocks|
    mocks.yield_receiver_to_any_instance_implementation_blocks = false
  end
end

module TestManager
  OBJECTS_FILE_NAME = 'spec/ipfs_objects.yaml'.freeze
  PINNED_FILE_NAME = 'spec/ipfs_pinned_objects.yaml'.freeze

  def self.included(clazz)
    clazz.send(:extend, ClassMethods)
  end

  def backup_gc_file
    FileUtils.copy_file('spec/samples/pinned_objects.yaml', PINNED_FILE_NAME)
  end

  def mock_fail_on_error
    allow_any_instance_of(Object).to receive(:fail_on_error, &add_to_actions)
  end

  def stub_ipfs_file_defaults
    stub_const('Schwifty::Content::Defaults::OBJECTS_FILE_NAME', OBJECTS_FILE_NAME)
    stub_const('Schwifty::Content::Defaults::PINNED_FILE_NAME', PINNED_FILE_NAME)
  end

  def remove_objects_file
    file = Schwifty::Content::Defaults::OBJECTS_FILE_NAME
    File.delete(file) if File.exist?(file)
  end

  def remove_pinned_file
    file = File.join(Schwifty::Content::Defaults::PINNED_FILE_NAME)
    File.delete(file) if File.exist?(file)
  end

  module ClassMethods
    def setup_tests
      track_shell_actions
      setup_default_test_values

      before do
        stub_ipfs_file_defaults
        mock_fail_on_error
      end

      before(:each) do
        remove_objects_file
        remove_pinned_file
      end
    end

    def setup_default_test_values
      let(:dir)   { 'spec/samples/files' }
      let(:file1) { 'spec/samples/files/file1' }
      let(:file2) { 'spec/samples/files/dir1/file2' }
      let(:hash1) { 'QmXMSyJvaz912Wi6533MegwUn4mJ4kQikaBZpAdeFwoWkj' }
      let(:hash2) { 'Qmenn1xp6bq5JJhE1hjsishPLeohEsWTq2GHWc2CspixZH' }
      let(:dst)   { '/Users/build' }
    end

    def setup_gc_tests
      let(:blocks)                      { 15 }
      let(:blocks_free_initially)       { 0 }
      let(:blocks_free_after_first_gc)  { 1 }
      let(:blocks_free_after_second_gc) { 2 }
      let(:blocks_below_threshold)      { 10 }

      let(:pinned_objects_file) { 'spec/samples/pinned_gc.yaml' }
      let(:pinned_aftermath_1)  { 'spec/samples/pinned_aftermath_1.yaml' }
      let(:pinned_aftermath_2)  { 'spec/samples/pinned_aftermath_2.yaml' }

      let(:hashes_to_unpin_first) do
        %w(QmQgxwAj14qCzcRLTrBDMnk6NQF2ho2Sk5MuMk1DUjTtrR
           QmcgYsEFP9E524EMXEhCPCcDSfn1xrE9JEJgJxsWB1VCiv
           QmNteSGaYGnSfBZGzJPj1nV5g2tJV3ht6p9CEo49mNPzoF
           QmRzzW9yUMpfhJveHqY5unzmAu77psEe9EjuHG7iiXLX3C
           QmRSxos7FYiPNm7bwxQf77gVNeEd6XR3tDmfyRp5UbH3ct
           QmTBm2RNsPdi1K8NEecYihx4HfQmv5ZmstqbagEmSRsViu
           QmNymYNQGPzuTy2G4akUaBZNKLgNVmAzK6q2cG2V85gHqg
           QmXYciy4T1dZAWp2JW2caPoK9ktJ54cuJoG8aAmkXRkJWq
           QmWZsfo5eNxTw7MTQkPESn7DxZSABg7RdELmiMbH6LMCF3
           QmeZfP6TG56WJxkg6LXwaBGQHj8zF7Kh9cqnh2bE5xoJtd
           QmZXYwLpuGd8kR51FU5f8U5M8M1LHPSUxMeFBtrNWwJGdE
           QmP3kAzhQWGvbYQLNaWYH9aZrhc6UmanCHRda8jY8hiLeu
           QmPLgX5XkhhkLKBDtFvQGZzZ7HyifsS1ayue2KmRyMvqqA
           QmcrtgYzkc8EVWXzA7bdjyY1xjFbViVBGGnNH3hxtGjAsY
           QmcAuuR5Xa5rsBKqxagRZRtp3viSQCWYMhos2qBQoWZV8q)
      end

      let(:hashes_to_unpin_second) do
        %w(QmWgrUrhSBgCRrAmJgNN8knu2mcWLFAfmUBbuA8ntUuTUP
           QmXMSyJvaz912Wi6533MegwUn4mJ4kQikaBZpAdeFwoWkj
           QmUZtwd6EQGyQbrwoTVFUEcmrXoo32o3qLkayMrEmr9fed
           QmUnyWvC4hFqYrE14PiYgHEm8Y6tmxo31w689zGEraXNnD
           QmQPTGKzrsA9SBYSCGLrYrMdTG68X4JBe2VMk6Uyxz9vi9
           QmfFUHbrmCTGbaQzNtKyiY9WLNZcUDTzPXofMqyri58JZn
           QmSsF4xjCAcpY3634TpKdBjHNnncWcQCrjyJqePUpdVjoX
           QmQNRHoDmwMtq8WyenFfVR1FzzGh9S5NTxNGfaCg7ioPnQ
           Qmenn1xp6bq5JJhE1hjsishPLeohEsWTq2GHWc2CspixZH
           QmdsndW7XchtXA1GcBRT8dn9SXeQ656ixJg9Fkq3X48aK4)
      end
    end

    def setup_ipfs_add_output
      setup_ipfs_add_dir_output

      let(:input_with_file1) { ['ipfs', 'add', '-q', file1] }
      let(:input_with_file2) { ['ipfs', 'add', '-q', file2] }
      let(:input_with_dir)   { ['ipfs', 'add', '-r', dir] }

      # ---
      # file1: QmXMSyJvaz912Wi6533MegwUn4mJ4kQikaBZpAdeFwoWkj
      let(:objects_with_file1)  { 'spec/samples/objects_one.yaml' }

      # ---
      # QmXMSyJvaz912Wi6533MegwUn4mJ4kQikaBZpAdeFwoWkj: time
      let(:pinned_with_file1) { 'spec/samples/pinned_one.yaml' }

      # ---
      # file1: QmXMSyJvaz912Wi6533MegwUn4mJ4kQikaBZpAdeFwoWkj
      # file2: Qmenn1xp6bq5JJhE1hjsishPLeohEsWTq2GHWc2CspixZH
      let(:objects_with_file1_and_file2) { 'spec/samples/objects_many.yaml' }

      # ---
      # QmXMSyJvaz912Wi6533MegwUn4mJ4kQikaBZpAdeFwoWkj: time
      # Qmenn1xp6bq5JJhE1hjsishPLeohEsWTq2GHWc2CspixZH: time
      let(:pinned_with_file1_and_file2) { 'spec/samples/pinned_many.yaml' }

      # ---
      # files/dir1/file2: Qmenn1xp6bq5JJhE1hjsishPLeohEsWTq2GHWc2CspixZH
      # files/file1: QmXMSyJvaz912Wi6533MegwUn4mJ4kQikaBZpAdeFwoWkj
      # files/dir1: QmSsF4xjCAcpY3634TpKdBjHNnncWcQCrjyJqePUpdVjoX
      # files: QmXYciy4T1dZAWp2JW2caPoK9ktJ54cuJoG8aAmkXRkJWq
      let(:objects_with_dir)  { 'spec/samples/objects_dir.yaml' }

      # ---
      # Qmenn1xp6bq5JJhE1hjsishPLeohEsWTq2GHWc2CspixZH: time
      # QmXMSyJvaz912Wi6533MegwUn4mJ4kQikaBZpAdeFwoWkj: time
      # QmSsF4xjCAcpY3634TpKdBjHNnncWcQCrjyJqePUpdVjoX: time
      # QmXYciy4T1dZAWp2JW2caPoK9ktJ54cuJoG8aAmkXRkJWq: time
      let(:pinned_with_dir) { 'spec/samples/pinned_dir.yaml' }
    end

    def setup_ipfs_add_dir_output
      let(:ipfs_add_dir_output) do
        %(added Qmenn1xp6bq5JJhE1hjsishPLeohEsWTq2GHWc2CspixZH files/dir1/file2
added QmXMSyJvaz912Wi6533MegwUn4mJ4kQikaBZpAdeFwoWkj files/file1
added QmSsF4xjCAcpY3634TpKdBjHNnncWcQCrjyJqePUpdVjoX files/dir1
added QmXYciy4T1dZAWp2JW2caPoK9ktJ54cuJoG8aAmkXRkJWq files)
      end
    end

    def track_shell_actions
      let(:actions) { [] }

      let(:add_to_actions) do
        ->(*cmd, **opts) { actions << { cmd: cmd, opts: opts } }
      end
    end
  end
end
