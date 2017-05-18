require 'spec_helper'
require 'test_manager'

describe Schwifty::Commands::Add do
  include TestManager
  setup_tests
  setup_ipfs_add_output

  before do
    inputs = [input_with_file1, input_with_file2, input_with_dir]
    results = [hash1, hash2, ipfs_add_dir_output]
    inputs.zip(results).each do |input, result|
      allow(described_class).to receive(:fail_on_error).with(*input).and_return(result)
    end

    allow_any_instance_of(Time).to receive(:getutc).and_return('time')
  end

  describe '.run' do
    it 'adds one file' do
      expect(described_class).to receive(:fail_on_error).with(*input_with_file1)
      described_class.run(file1)
      expect(FileUtils.cmp(Schwifty::Content::Defaults::OBJECTS_FILE_NAME, objects_with_file1)).to be_truthy
      expect(FileUtils.cmp(Schwifty::Content::Defaults::PINNED_FILE_NAME, pinned_with_file1)).to be_truthy
    end

    it 'adds multiple files' do
      expect(described_class).to receive(:fail_on_error).with(*input_with_file1)
      expect(described_class).to receive(:fail_on_error).with(*input_with_file2)
      described_class.run(file1, file2)
      expect(FileUtils.cmp(Schwifty::Content::Defaults::OBJECTS_FILE_NAME, objects_with_file1_and_file2)).to be_truthy
      expect(FileUtils.cmp(Schwifty::Content::Defaults::PINNED_FILE_NAME, pinned_with_file1_and_file2)).to be_truthy
    end

    it 'adds directories' do
      expect(described_class).to receive(:fail_on_error).with(*input_with_dir)
      described_class.run(dir)
      expect(FileUtils.cmp(Schwifty::Content::Defaults::OBJECTS_FILE_NAME, objects_with_dir)).to be_truthy
      expect(FileUtils.cmp(Schwifty::Content::Defaults::PINNED_FILE_NAME, pinned_with_dir)).to be_truthy
    end
  end
end
