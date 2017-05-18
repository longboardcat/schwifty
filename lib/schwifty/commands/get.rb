require 'build_execution'

require 'schwifty/content/objects_file'

module Schwifty
  module Commands
    # Get allows us to download valid files in the Objects File or try a hash directly.
    class Get
      def self.run(*filenames_or_hashes, dst: '.')
        filenames_or_hashes.each do |key|
          key = Schwifty::Content::ObjectsFile.new.get(key) unless hash?(key)
          fail_on_error('ipfs', 'get', key, "--output='#{dst}'")
        end
      end

      private_class_method def self.hash?(str)
        str.length == 46 && str[/[a-zA-Z0-9]+/] == str
      end
    end
  end
end
