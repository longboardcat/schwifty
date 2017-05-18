require 'spec_helper'
require 'test_manager'

describe Schwifty::Content::HashFile do
  include TestManager
  setup_tests

  let(:filename) { 'spec/samples/objects_dir.yaml' }
  let(:default_instance) { described_class.new(filename) }

  before do
    allow_any_instance_of(described_class).to receive(:save_yaml)
  end

  describe '#add_entries' do
    context 'for a single entry' do
      it 'adds' do
        expect(default_instance).to receive(:save_yaml)
        entries = default_instance.send(:load_yaml)
        entries[:key1] = 'val1'
        default_instance.add_entries([:key1], ['val1'])
        expect(default_instance.instance_variable_get(:@entries)).to eq(entries)
      end

      context 'with collisions allowed' do
        it 'adds' do
          expect(default_instance).to receive(:save_yaml)
          entries = default_instance.send(:load_yaml)
          default_instance.add_entries([file1], [hash1], allow_collisions: true)
          expect(default_instance.instance_variable_get(:@entries)).to eq(entries)
        end
      end

      context 'without collisions allowed' do
        it 'raises for a collision' do
          expect(default_instance).not_to receive(:save_yaml)
          expect { default_instance.add_entries([file1], [hash1]) }
            .to raise_error(RuntimeError,
                            "Schwifty::Content::HashFile collision when inserting #{file1}, #{hash1}")
        end
      end
    end

    context 'with multiple entries' do
      it 'adds' do
        expect(default_instance).to receive(:save_yaml)
        entries = default_instance.send(:load_yaml)
        entries[:key1] = 'val1'
        entries[:key2] = 'val2'
        default_instance.add_entries([:key1, :key2], %w(val1 val2), allow_collisions: true)
        expect(default_instance.instance_variable_get(:@entries)).to eq(entries)
      end

      context 'with collisions allowed' do
        it 'adds' do
          expect(default_instance).to receive(:save_yaml)
          entries = default_instance.instance_variable_get(:@entries)
          default_instance.add_entries([file1, :key1], [hash1, 'val1'], allow_collisions: true)
          expect(default_instance.instance_variable_get(:@entries)).to eq(entries)
        end
      end

      context 'without collisions allowed' do
        it 'raises for a single collision' do
          expect(default_instance).not_to receive(:save_yaml)
          expect { default_instance.add_entries([:key1, file1], ['val1', hash1]) }
            .to raise_error(RuntimeError,
                            "Schwifty::Content::HashFile collision when inserting #{file1}, #{hash1}")
        end
      end
    end
  end

  describe '#get' do
    context 'with a valid key' do
      it 'gets the value' do
        expect(default_instance.get(file1)).to eq(hash1)
      end
    end

    context 'with an invalid key' do
      it 'raises' do
        expect { default_instance.get('blah') }
          .to raise_error(RuntimeError, 'Schwifty::Content::HashFile value does not exist for: blah')
      end
    end
  end

  describe '#remove_entry' do
    it 'removes an entry' do
      entries = default_instance.instance_variable_get(:@entries)
      entries.delete(file1)
      default_instance.remove_entry(file1)
      expect(default_instance.instance_variable_get(:@entries)).to eq(entries)
    end
  end
end
