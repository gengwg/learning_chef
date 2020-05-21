#
# Cookbook Name:: myhaproxy
# Recipe:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

node.default['haproxy']['members'] = [
{
    'hostname' => 'ec2-54-85-120-244.compute-1.amazonaws.com',
    'ipaddress' => '54.85.120.244',
    'port' => 80,
    'ssl_port' => 80
  }, {
    'hostname' => 'ec2-54-92-185-51.compute-1.amazonaws.com',
    'ipaddress' => '54.92.185.51',
    'port' => 80,
    'ssl_port' => 80
}]

include_recipe 'haproxy::default'

