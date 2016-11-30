ZAmerica 1.0.3
===========

What is ZAmerica?
--------------

[ZAmerica] is an implementation of the "Zerocash" protocol forked from [ZAmerica].
Based on Bitcoin's code, it intends to offer a far higher standard of privacy
through a sophisticated zero-knowledge proving scheme that preserves
confidentiality of transaction metadata. Technical details are available
in [Protocol Specification](https://github.com/zamerica/zips/raw/master/protocol/protocol.pdf).

This software is the ZAmerica client. It downloads and stores the entire history
of ZAmerica transactions; depending on the speed of your computer and network
connection, the synchronization process could take a day or more once the
block chain has reached a significant size.

Security Warnings
-----------------

See important security warnings in
[doc/security-warnings.md](doc/security-warnings.md).

**ZAmerica is unfinished and highly experimental.** Use at your own risk.

Where do I begin?
-----------------
We have a guide for joining the main ZAmerica network:
https://github.com/zamerica/zamerica/wiki/1.0-User-Guide

Building
--------

Build ZAmerica along with most dependencies from source by running
./zcutil/build.sh. Currently only Linux is officially supported.

You need to run ./zcutil/fetch-params.sh before first start.

License
-------

For license information see the file [COPYING](COPYING).
