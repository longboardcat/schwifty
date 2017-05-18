require 'time'
require 'yaml'

require 'schwifty/content/defaults'
require 'schwifty/content/hash_file'

module Schwifty
  module Content
    # The Pinned Objects File keeps track of hash : timestamp mappings. Remember: a file must
    # remain on a single host to exist in the cluster, but we need to keep track of space usage.
    #
    # ---
    # Qmb1CkJmfpwmyLvuPMMRKKpYPuiwUMW9V1WdbFLVZgAdpL: 2016-06-01 01:04:49 UTC
    #
    class PinnedFile < Schwifty::Content::HashFile
      def initialize(filename = Schwifty::Content::Defaults::PINNED_FILE_NAME)
        super(filename)
      end

      # Remove hashes from the Pinned Objects File using a threshold. Does not do any garbage
      # collection on its own. Return a list of hashes to be GC'ed.
      def cull(threshold = Schwifty::Content::Defaults::GC_CULL_THRESHOLD)
        num_to_remove = num_entries - (threshold * num_entries).to_int
        entries_to_remove = @entries.sort_by { |_hash, date| date }[0..num_to_remove].map(&:first)
        entries_to_remove.each { |key| remove_entry(key) }
        save_yaml
        entries_to_remove
      end
    end
  end
end
