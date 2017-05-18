require 'spec_helper'
require 'test_manager'

describe Schwifty::Commands::Get do
  include TestManager
  setup_tests

  describe '.run' do
    before(:each) do
      stub_const('Schwifty::Content::Defaults::OBJECTS_FILE_NAME', 'spec/samples/objects_dir.yaml')
    end

    let(:get_output_one_file) do
      [{ cmd: ['ipfs', 'get', hash1, "--output='.'"],
         opts: {} }]
    end

    let(:get_output_multiple_files) do
      [{ cmd: ['ipfs', 'get', hash1, "--output='.'"],
         opts: {} },
       { cmd: ['ipfs', 'get', hash2, "--output='.'"],
         opts: {} }]
    end

    let(:get_output_with_dst) do
      [{ cmd: ['ipfs', 'get', hash1, "--output='#{dst}'"],
         opts: {} }]
    end

    context 'using filenames' do
      it 'gets one file' do
        described_class.run(file1)
        expect(actions).to eq(get_output_one_file)
      end

      it 'gets multiple files' do
        described_class.run(file1, file2)
        expect(actions).to eq(get_output_multiple_files)
      end
    end

    context 'using hashes' do
      it 'gets one file' do
        described_class.run(hash1)
        expect(actions).to eq(get_output_one_file)
      end

      it 'gets multiple files' do
        described_class.run(hash1, hash2)
        expect(actions).to eq(get_output_multiple_files)
      end
    end

    it 'changes destination' do
      described_class.run(hash1, dst: dst)
      expect(actions).to eq(get_output_with_dst)
    end
  end
end
