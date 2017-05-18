require 'spec_helper'
require 'test_manager'

describe Schwifty::Content::AddParser do
  include TestManager
  setup_ipfs_add_dir_output

  let(:filenames) { ['files/dir1/file2', 'files/file1', 'files/dir1', 'files'] }
  let(:hashes) do
    %w(Qmenn1xp6bq5JJhE1hjsishPLeohEsWTq2GHWc2CspixZH
       QmXMSyJvaz912Wi6533MegwUn4mJ4kQikaBZpAdeFwoWkj
       QmSsF4xjCAcpY3634TpKdBjHNnncWcQCrjyJqePUpdVjoX
       QmXYciy4T1dZAWp2JW2caPoK9ktJ54cuJoG8aAmkXRkJWq)
  end

  describe '.run' do
    it 'parses multiline output' do
      parsed_filenames, parsed_hashes = described_class.run(ipfs_add_dir_output)
      expect(parsed_filenames).to eq(filenames)
      expect(parsed_hashes).to eq(hashes)
    end
  end
end
