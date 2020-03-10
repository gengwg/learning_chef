#
# Cookbook:: .
# Recipe:: server
#
# Copyright:: 2020, The Authors, All Rights Reserved.
#
package 'httpd' do
  action :install
end

file '/var/www/html/index.html' do
  content "<h1>Hello, world!</h1>
  ipaddress: #{ node['ipaddress'] }
  hostname: #{node['hostname']}
"
end

service 'httpd' do
  action [:start, :enable]
end


