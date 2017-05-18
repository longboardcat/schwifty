# schwifty

[![Build Status](https://travis-ci.org/longboardcat/schwifty.svg?branch=master)](https://travis-ci.org/longboardcat/schwifty)

[ipfs][1] is a distributed file system that is content-addressed and uses keys (hashes) to files
(objects). This repo uses the hash/object terminology consistent with the rest of ipfs docs.

## Usage

```bash
schwifty add <files>...
schwifty bootstrap (--clear | <nodes>... | --file=<bootstrap_list_yaml>)
schwifty get <files_or_hashes>...
schwifty gc
schwifty -h | --help
schwifty --version
```

## Hash Files

Because ipfs does not have a typical Unix file system structure, we keep track of files added using
the `ipfs add` operation. This task is entrusted to two files, one of which any client code needs to
interact with and the other for garbage collection purposes. Both of these files are in `.yaml` form.

For the examples below, we'll use the convention in `bin/console` where `client = IPFS::Client`.

### Objects File: `ipfs_objects.yaml`

It's your job read and manipulate this file and pass it between steps of your build/test pipeline.
The objects file contains a mapping of filename : hash

`client.add('spec/samples/files/file1')`

```yaml
---
spec/samples/files/file1: QmXMSyJvaz912Wi6533MegwUn4mJ4kQikaBZpAdeFwoWkj
```

`client.get('spec/samples/files/file1')` will download the file to the current directory.
Both `add` and `get` can take multiple files.

### Pinned Objects File: `~/.ipfs/ipfs_pinned_objects.yaml`

A hash : timestamp is written in this file every time `ipfs add` is run. `ipfs add` pins objects by
default. You aren't expected to interact with this file, but it may help in debugging purposes.

```yaml
---
Qmb1CkJmfpwmyLvuPMMRKKpYPuiwUMW9V1WdbFLVZgAdpL: 2016-06-01 01:04:49 UTC
QmZXYwLpuGd8kR51FU5f8U5M8M1LHPSUxMeFBtrNWwJGdE: 2016-05-31 12:41:19 UTC
```

Garbage collection (GC) follows these rules:
1. Check for disk space. If disk space is below the threshold (0.85), do not GC.
2. Run `ipfs repo gc` to remove all unpinned objects.
3. Check for disk space. If disk space is above the threshold, go to step 4.
4. Unpin one third of objects from the Pinned Objects File.
5. Run `ipfs repo gc` to remove the unpinned objects.
6. Back to step 3.

There's no backoff in the GC unpin rate in step 4, and the gem doesn't know how much disk space will
be freed every call. The 1/3 of hashes removed each time does get smaller though.

### Bootstrapping

We recommend checking in an approved bootstrap list that, in tandem with the CLI, bootstraps nodes
via a configuration managed provisioning tool (like Ansible). The CLI supports bootstrapping via
a `.yaml` file with hostname : multiaddr/peerID formats. See `ipfs bootstrap` and `ipfs id` docs
for more info.

```yaml
---
hostname1: /ip4/127.0.0.1/tcp/4001/ipfs/QaowiA9HvLCinkCLwRFauHkAZUP3DQDogku98r9BctEhgc
hostname2: /ip4/192.112.0.101/tcp/4001/ipfs/QmcpER9AOSUinkCLwRFi8zkAZU73DQDogkF98r9BctEhgc
```

[1]: https://ipfs.io/
