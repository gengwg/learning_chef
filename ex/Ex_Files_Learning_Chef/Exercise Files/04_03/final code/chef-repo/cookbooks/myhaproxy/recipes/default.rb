#
# Cookbook Name:: myhaproxy
# Recipe:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

node.default['haproxy']['members'] = [
{
    'hostname' => 'web1_PUBLIC_HOSTNAME',
    'ipaddress' => 'web1_PUBLIC_IPADDRESS',
    'port' => 80,
    'ssl_port' => 80
  }, {
    'hostname' => 'web2_PUBLIC_HOSTNAME',
    'ipaddress' => 'web2_PUBLIC_IPADDRESS',
    'port' => 80,
    'ssl_port' => 80
}]

include_recipe 'haproxy::default'

