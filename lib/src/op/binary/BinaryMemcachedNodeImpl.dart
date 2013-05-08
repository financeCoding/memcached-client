//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  09:34:10 AM
// Author: hernichen

part of memcached_client;

class BinaryMemcachedNodeImpl extends MemcachedNode {
  //TODO: would multiple opChannels in a node a better implementation?
  final BinaryOPChannel _opChannel;
  BinaryMemcachedNodeImpl(SocketAddress saddr, AuthDescriptor authDescriptor)
      : _opChannel = new BinaryOPChannel(saddr, authDescriptor),
        super(saddr);

  OPChannel get opChannel => _opChannel;
}

