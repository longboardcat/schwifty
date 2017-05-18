require 'spec_helper'
require 'test_manager'

describe Schwifty::Content::PinnedFile do
  include TestManager
  setup_tests
  setup_gc_tests

  let(:default_instance) { described_class.new }

  before(:each) do
    backup_gc_file
    allow_any_instance_of(described_class).to receive(:save_yaml)
  end

  describe '#cull' do
    it 'removes entries' do
      expect(default_instance).to receive(:save_yaml)
      hashes_to_unpin_first.each do |hash|
        expect(default_instance).to receive(:remove_entry).with(hash)
      end
      expect(default_instance.cull).to eq(hashes_to_unpin_first)
    end
  end
end
