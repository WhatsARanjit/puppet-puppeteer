#!/usr/bin/env ruby
require 'beaker-rspec'
require 'beaker/module_install_helper'

def run_puppet_access_login(user:, password: 'puppetlabs', lifetime: '5y')
  on(master, puppet('access', 'login', '--username', user, '--lifetime', lifetime), stdin: password)
end

def run_puppet_task(task_name:, params: nil)
  on(master, puppet('task', 'run', task_name, '--nodes', fact_on(default, 'fqdn'), params.to_s), acceptable_exit_codes: [0, 1]).stdout
end

def expect_multiple_regexes(result:, regexes:)
  regexes.each do |regex|
    expect(result).to match(regex)
  end
end

def clear_env_cache(host)
  cmd_array = [
    '/usr/bin/curl',
    '-s -I -X DELETE',
    "--cert /etc/puppetlabs/puppet/ssl/certs/#{fact_on(default, 'fqdn')}.pem",
    "--key /etc/puppetlabs/puppet/ssl/private_keys/#{fact_on(default, 'fqdn')}.pem",
    '--cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem',
    "https://#{fact_on(default, 'fqdn')}:8140/puppet-admin-api/v1/environment-cache?environment=production",
  ]
  on(host, "#{cmd_array.join(' ')}")
end

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
  end
end

pe_opts = {
  :answers => {
    'console_admin_password'                                          => 'puppetlabs',
    'puppet_enterprise::puppet_master_host'                           => '%{::trusted.certname}',
    'puppet_enterprise::profile::master::code_manager_auto_configure' => true,
    'puppet_enterprise::profile::master::r10k_remote'                 => 'https://github.com/puppetlabs/control-repo.git',
  }
}

hosts.each do |host|

  if host['roles'].include?('master')
    install_pe_on(host, pe_opts)
    run_puppet_access_login(user: 'admin')
    install_module_on(host)
    clear_env_cache(host)
  else
    install_puppet_agent_on(host)
  end
end
