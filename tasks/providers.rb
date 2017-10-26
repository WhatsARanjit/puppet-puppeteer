#!/opt/puppetlabs/puppet/bin/ruby
require 'puppet'
Puppet.initialize_settings

def find_providers(type)
  t = Puppet::Type.type(type.to_sym)
  if t
    t.providers.map { |p| p.to_s if t.validprovider?(p) }.compact
  else
    raise 'Type does not exist.'
  end
end

params = JSON.parse(STDIN.read)
type   = params['type']
# For testing
#type   = 'user'

begin
  puts({ 'providers' => find_providers(type), }.to_json)
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
