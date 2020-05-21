#
# Cookbook Name:: apache
# Recipe:: server
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

package 'httpd'

file '/var/www/html/index.html' do
  content "<h1>Hello, world!</h1>
  ipaddress: #{node['ipaddress']}
  hostname: #{node['hostname']}
"
end

service 'httpd' do
  action [:start, :enable]
end