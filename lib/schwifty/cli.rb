require 'docopt'

require 'schwifty/client'
require 'schwifty/info'

module Schwifty
  # This class acts as the command line interface for the IPFS client. Args are parsed using the
  # docopt template below.
  class CLI
    def run
      opts = parse_args

      if opts['add']
        Schwifty::Client.add(*opts['<files>'])
      elsif opts['bootstrap']
        Schwifty::Client.bootstrap(*opts['<nodes>'], clear: opts['--clear'], filename: opts['--file'])
      elsif opts['get']
        Schwifty::Client.add(*opts['<files_or_hashes>'])
      elsif opts['gc']
        Schwifty::Client.gc
      elsif opts['--version']
        puts "schwifty version #{Schwifty::VERSION}"
      end
    end

    # Modify this to change how the CLI works -- see http://docopt.org/
    def parse_args
      doc = <<DOCOPT
schwifty saves and downloads objects from ipfs, keeping track of their hashes in a garbage collection file in ~/.ipfs/ipfs_pinned_objects.yaml and an objects file in ./ipfs_objects.yaml

Usage:
  schwifty add <files>...
  schwifty bootstrap (--clear | <nodes>... | --file=<bootstrap_list_yaml>)
  schwifty get <files_or_hashes>...
  schwifty gc
  schwifty -h | --help
  schwifty --version

Options:
  -h --help     Show this screen.
  --version     Show version.
DOCOPT
      begin
        Docopt.docopt(doc)
      rescue Docopt::Exit => e
        puts e.message
        exit
      end
    end
  end
end
