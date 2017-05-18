require 'spec_helper'
require 'test_manager'

describe Schwifty::Commands::Bootstrap do
  include TestManager
  setup_tests

  before do
    allow(described_class).to receive(:fail_on_error, &add_to_actions)
  end

  describe '.run' do
    let(:hostnames) do
      %w(hostname1 hostname2)
    end

    let(:bootstrap_yaml) { 'spec/samples/bootstrap.yaml' }

    let(:multiaddrs) do
      %w(/ip4/127.0.0.1/tcp/4001/ipfs/QaowiA9HvLCinkCLwRFauHkAZUP3DQDogku98r9BctEhgc
         /ip4/192.112.0.101/tcp/4001/ipfs/QmcpER9AOSUinkCLwRFi8zkAZU73DQDogkF98r9BctEhgc)
    end

    let(:bootstrap_nodes_result) { [{ cmd: ['ipfs', 'bootstrap', 'add', *multiaddrs], opts: {} }] }
    let(:bootstrap_list_cmd)     { %w(ipfs bootstrap list) }
    let(:bootstrap_list_result)  { multiaddrs.join("\n") }

    it 'adds files' do
      described_class.run(*multiaddrs)
      expect(actions).to eq(bootstrap_nodes_result)
    end

    it 'clears the bootstrap list' do
      allow(described_class)
        .to receive(:fail_on_error).with(*bootstrap_list_cmd).and_return(bootstrap_list_result)
      described_class.run(clear: true)
      expect(actions).to eq [{ cmd: ['ipfs', 'bootstrap', 'rm', *multiaddrs], opts: {} }]
    end

    it 'parses a bootstrap file' do
      described_class.run(filename: bootstrap_yaml)
      expect(actions).to eq(bootstrap_nodes_result)
    end
  end
end
