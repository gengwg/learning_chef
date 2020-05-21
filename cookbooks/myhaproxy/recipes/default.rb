#
# Cookbook:: myhaproxy
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.
#

# define a new node attribute
node.default['haproxy']['members'] = [
  {
    "hostname" => "localhost",  # replace with aws node
    "ipaddress" => "127.0.0.1",
    "port" => 80,
    "ssl_port" => 80
  }, {
    "hostname" => "localhost",
    "ipaddress" => "127.0.0.1",
    "port" => 80,
    "ssl_port" => 80
  }]

include_recipe 'haproxy::default'
