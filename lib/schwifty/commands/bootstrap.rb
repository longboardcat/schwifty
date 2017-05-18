require 'build_execution'
require 'yaml'

module Schwifty
  module Commands
    # Bootstrapping individual worker nodes. '<multiaddr>/<peerID>' format required.
    class Bootstrap
      def self.run(*nodes, clear: false, filename: nil)
        if clear
          bootstrap_clear
        elsif filename
          bootstrap_file(filename)
        else
          bootstrap_nodes(*nodes)
        end
      end

      private_class_method

      def self.bootstrap_clear
        existing_nodes = fail_on_error('ipfs', 'bootstrap', 'list').split("\n")
        if existing_nodes.empty?
          puts "#{self.class.name}: No nodes in bootstrap list!"
        else
          fail_on_error('ipfs', 'bootstrap', 'rm', *existing_nodes)
        end
      end

      # Bootstrap file is a mapping of hostname : '<multiaddr>/<peerID>' formats.
      def self.bootstrap_file(filename)
        bootstrap_nodes(*YAML.load_file(filename).values)
      end

      def self.bootstrap_nodes(*nodes)
        fail_on_error('ipfs', 'bootstrap', 'add', *nodes)
      end
    end
  end
end
