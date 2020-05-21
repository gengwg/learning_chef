# # encoding: utf-8

# Inspec test for recipe apache::server

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

describe port(80) do
  it { should_not be_listening }
end

describe command('curl localhost') do
  its(:stdout) { should match(/Hello, world!/)}
end