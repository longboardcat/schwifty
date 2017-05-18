module Schwifty
  module Content
    # Parses ipfs add -r output to return a list of filenames and their hashes
    class AddParser
      def self.run(output)
        filenames = []
        hashes = []

        output.split("\n").each do |line|
          words = line.split(' ')
          index = words.index('added')
          hashes << words[index + 1]
          filenames << words[index + 2]
        end

        [filenames, hashes]
      end
    end
  end
end
