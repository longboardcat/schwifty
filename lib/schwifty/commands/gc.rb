require 'build_execution'
require 'sys/filesystem'

require 'schwifty/content/pinned_file'

module Schwifty
  module Commands
    # Garbage collection to be called via CLI. If there's not enough disk space after a blind call
    # to GC unpinned objects, we GC pinned objects as well. Pinned GC works by removing hashes
    # repeatedly until we're below the disk space threshold. We get hashes to remove from the
    # Pinned Objects File.
    class GC
      def self.run
        return unless disk_space_exceeds_threshold?
        gc

        while disk_space_exceeds_threshold?
          unpin(Schwifty::Content::PinnedFile.new.cull)
          gc
        end
      end

      private_class_method

      def self.disk_space_exceeds_threshold?
        stat = Sys::Filesystem.stat('/')
        (stat.blocks - stat.blocks_free) / stat.blocks.to_f > Schwifty::Content::Defaults::GC_DISK_THRESHOLD
      end

      def self.gc
        fail_on_error('ipfs', 'repo', 'gc')
      end

      def self.unpin(hashes)
        fail_on_error('ipfs', 'pin', 'rm', *hashes)
      end
    end
  end
end
