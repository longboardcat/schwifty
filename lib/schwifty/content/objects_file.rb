require 'yaml'

require 'schwifty/content/defaults'
require 'schwifty/content/hash_file'

module Schwifty
  module Content
    # The Objects File keeps track of filename : hash mappings. Directories added recursively will
    # have all of their files' individual hashes added as well.
    #
    # ipfs add -r spec/samples
    #
    # ---
    # spec/samples/files/dir1/file2: Qmenn1xp6bq5JJhE1hjsishPLeohEsWTq2GHWc2CspixZH
    # spec/samples/files/file1: QmXMSyJvaz912Wi6533MegwUn4mJ4kQikaBZpAdeFwoWkj
    # spec/samples/files/dir1: QmSsF4xjCAcpY3634TpKdBjHNnncWcQCrjyJqePUpdVjoX
    # spec/samples/files: QmXYciy4T1dZAWp2JW2caPoK9ktJ54cuJoG8aAmkXRkJWq
    #
    class ObjectsFile < Schwifty::Content::HashFile
      def initialize(filename = Schwifty::Content::Defaults::OBJECTS_FILE_NAME)
        super(filename)
      end
    end
  end
end
