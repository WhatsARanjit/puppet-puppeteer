#!/opt/puppetlabs/puppet/bin/ruby
require 'puppet/application/apply'
require 'tempfile'

Puppet.initialize_settings
# https://github.com/puppetlabs/puppet/blob/master/lib/puppet/util/log/destinations.rb#L100
# Agent defaults to puppet:puppet, but puppet user is not created by default
Puppet.settings[:user]  = '0'
Puppet.settings[:group] = '0'

# Catch the apply()'s exit
at_exit do
  begin
    puts File.read(@tmp_log.path)
    @tmp_log.unlink
    #File.delete(tmp_log)
  rescue Errno::ENOENT => e
  end
end

@tmp_log = Tempfile.new('puppeteer_apply')

def puppet_apply(pp, dsl)
  pp.handle_logdest_arg(@tmp_log.path)
  pp.options[:code] = dsl
  pp.main
end

params   = JSON.parse(STDIN.read)
code     = params['code']
manifest = params['manifest']
noop     = params['_noop']

# Set modulepath if given
Puppet.settings[:modulepath] = params['modulepath'] if params.key?('modulepath')

raise 'Please specify either \'code\' or \'manifest\' option' if ( code and manifest )

Puppet.settings[:noop] = true if noop

begin
  pp  = Puppet::Application::Apply.new
  dsl = code || File.read(manifest)
  puppet_apply(pp, dsl)
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
