#!/opt/puppetlabs/puppet/bin/ruby
require 'puppet'
Puppet.initialize_settings

def get_classfile
  File.read(Puppet['classfile']).split("\n").sort
end

params = JSON.parse(STDIN.read)
# For testing
#params = Hash.new

begin
  puts(get_classfile.to_json)
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
