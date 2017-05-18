require 'build_execution'
require 'time'

require 'schwifty/content/objects_file'
require 'schwifty/content/parsers'
require 'schwifty/content/pinned_file'

module Schwifty
  module Commands
    # This class adds objects to ipfs and tracks their hashes using the Objects File and Pinned
    # Objects File.
    class Add
      def self.run(*filenames)
        result_filenames = []
        result_hashes = []

        # Parse add command outputs
        filenames.each do |name|
          parsed_filenames, parsed_hashes = Dir.exist?(name) ? add_dir(name) : add_file(name)
          result_filenames += parsed_filenames
          result_hashes += parsed_hashes
        end

        update_hash_files(result_filenames, result_hashes)
      end

      private_class_method

      def self.add_dir(name)
        output = fail_on_error('ipfs', 'add', '-r', name)
        parsed_filenames, parsed_hashes = Schwifty::Content::AddParser.run(output)
        parsed_filenames.map! { |tail| File.join(File.dirname(name), tail) }
        [parsed_filenames, parsed_hashes]
      end

      def self.add_file(name)
        [[name], [fail_on_error('ipfs', 'add', '-q', name)]]
      end

      def self.update_hash_files(filenames, hashes)
        Schwifty::Content::ObjectsFile.new.add_entries(filenames, hashes)
        Schwifty::Content::PinnedFile.new.
          add_entries(hashes, [Time.now.getutc.to_s] * hashes.size, allow_collisions: true)
      end
    end
  end
end
