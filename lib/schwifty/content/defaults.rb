module Schwifty
  module Content
    module Defaults
      OBJECTS_FILE_NAME = 'ipfs_objects.yaml'.freeze
      PINNED_FILE_NAME = File.join(ENV['HOME'], '.ipfs', 'ipfs_pinned_objects.yaml').freeze

      # If we're above this threshold after an unpinned GC, we GC pinned objects as well.
      GC_DISK_THRESHOLD = 0.85 # TODO: Tune this value
      GC_CULL_THRESHOLD = 0.67 # TODO: Tune this value
    end
  end
end
