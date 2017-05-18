require 'spec_helper'
require 'test_manager'

describe Schwifty::Commands::GC do
  include TestManager
  setup_tests
  setup_gc_tests

  # Don't have an easy way to test gc without the daemon running. If we did, we could add, unpin,
  # gc, then see if get fails.
  before(:each) do
    backup_gc_file
  end

  context 'over the threshold' do
    context 'requiring one gc' do
      before do
        allow(Sys::Filesystem).to receive(:stat)
          .and_return(double(blocks: blocks, blocks_free: blocks_free_initially),
                      double(blocks: blocks, blocks_free: blocks_below_threshold))
      end

      it 'clears unpinned objects' do
        described_class.run
        expect(actions).to eq([{ cmd: %w(ipfs repo gc), opts: {} }])
      end
    end

    context 'requiring multiple gcs' do
      context 'when a single unpin is sufficient' do
        it 'calls gc and unpins once' do
          allow(Sys::Filesystem).to receive(:stat)
            .and_return(double(blocks: blocks, blocks_free: blocks_free_initially),
                        double(blocks: blocks, blocks_free: blocks_free_after_first_gc),
                        double(blocks: blocks, blocks_free: blocks_below_threshold))
          described_class.run
          expect(actions).to eq([{ cmd: %w(ipfs repo gc), opts: {} },
                                 { cmd: ['ipfs', 'pin', 'rm', *hashes_to_unpin_first], opts: {} },
                                 { cmd: %w(ipfs repo gc), opts: {} }])
          expect(FileUtils.cmp(Schwifty::Content::Defaults::PINNED_FILE_NAME, pinned_aftermath_1)).to be_truthy
        end
      end

      context 'when multiple unpins are needed' do
        it 'calls gc and unpins repeatedly' do
          allow(Sys::Filesystem).to receive(:stat)
            .and_return(double(blocks: blocks, blocks_free: blocks_free_initially),
                        double(blocks: blocks, blocks_free: blocks_free_after_first_gc),
                        double(blocks: blocks, blocks_free: blocks_free_after_second_gc),
                        double(blocks: blocks, blocks_free: blocks_below_threshold))
          described_class.run
          expect(actions).to eq([{ cmd: %w(ipfs repo gc), opts: {} },
                                 { cmd: ['ipfs', 'pin', 'rm', *hashes_to_unpin_first], opts: {} },
                                 { cmd: %w(ipfs repo gc), opts: {} },
                                 { cmd: ['ipfs', 'pin', 'rm', *hashes_to_unpin_second], opts: {} },
                                 { cmd: %w(ipfs repo gc), opts: {} }])
          expect(FileUtils.cmp(Schwifty::Content::Defaults::PINNED_FILE_NAME, pinned_aftermath_2)).to be_truthy
        end
      end
    end
  end

  context 'under the threshold' do
    before do
      allow(Sys::Filesystem).to receive(:stat)
        .and_return(double(blocks: blocks, blocks_free: blocks_below_threshold))
    end

    it 'does not call repo gc' do
      expect(described_class).not_to receive(:fail_on_error)
      described_class.run
    end
  end
end
