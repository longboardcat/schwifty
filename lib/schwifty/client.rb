require 'build_execution'

require 'schwifty/commands/add'
require 'schwifty/commands/bootstrap'
require 'schwifty/commands/gc'
require 'schwifty/commands/get'

module Schwifty
  # This class calls all the ipfs commands for the CLI or other use.
  class Client
    def self.add(*files)
      Commands::Add.run(*files)
      nil
    end

    def self.bootstrap(*nodes, clear: false, filename: nil)
      Commands::Bootstrap.run(*nodes, clear: clear, filename: filename)
      nil
    end

    def self.gc
      Commands::GC.run
      nil
    end

    def self.get(*filenames_or_hashes, dst: '.')
      Commands::Get.run(*filenames_or_hashes, dst)
      nil
    end
  end
end
