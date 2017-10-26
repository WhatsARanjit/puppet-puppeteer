#!/opt/puppetlabs/puppet/bin/ruby
require 'puppet'
Puppet.initialize_settings

def find_features
  f = Puppet.features
  f.load
  all_methods = f.methods - Object.methods
  # Load creates a feature_name? method for each feature
  all_methods.select { |m| m =~ /\?$/ }.map { |m| m.to_s.gsub(/\?$/, '') if f.send(m) }.compact
end

params = JSON.parse(STDIN.read)
# For testing
#params = Hash.new

begin
  puts({ 'features' => find_features, }.to_json)
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
