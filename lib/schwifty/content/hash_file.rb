require 'yaml'

module Schwifty
  module Content
    # IPFS file base class
    class HashFile
      def initialize(filename)
        @filename = filename
        @entries = load_yaml
      end

      def add_entries(keys, vals, allow_collisions: false)
        keys.zip(vals).each do |key, val|
          if @entries.key?(key) && !allow_collisions
            raise "#{self.class.name} collision when inserting #{key}, #{val}"
          end

          @entries[key] = val
        end

        save_yaml
      end

      def get(key)
        val = @entries[key.to_s]
        raise "#{self.class.name} value does not exist for: #{key}" unless val
        val
      end

      def remove_entry(key)
        @entries.delete(key)
      end

      def save_yaml
        File.open(@filename, 'w') { |f| f.write(@entries.to_yaml) }
      end

      private

      def load_yaml
        FileUtils.touch(@filename) unless File.exist?(@filename)
        YAML.load_file(@filename) || {}
      end

      def num_entries
        @entries.length
      end
    end
  end
end
