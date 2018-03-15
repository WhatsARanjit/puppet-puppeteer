#!/opt/puppetlabs/puppet/bin/ruby

require 'net/http'
require 'uri'
require 'puppet'

Puppet.initialize_settings

def clear_env_cache(env)
  url  = %(https://#{Puppet[:server]}:#{Puppet[:masterport]}/puppet-admin-api/v1/environment-cache?environment=#{env})
  uri  = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)

  Puppet.debug('Using SSL authentication')
  http.use_ssl     = true
  http.cert        = OpenSSL::X509::Certificate.new(File.read(Puppet[:hostcert]))
  http.key         = OpenSSL::PKey::RSA.new(File.read(Puppet[:hostprivkey]))
  http.ca_file     = Puppet[:localcacert]
  http.verify_mode = OpenSSL::SSL::VERIFY_CLIENT_ONCE

  req              = Net::HTTP.const_get('Delete').new(uri.request_uri)
  req.content_type = 'application/json'

  begin
    res = http.request(req)
  rescue StandardError => e
    debug(e.backtrace.inspect)
    raise(e.message)
  else
    res
  end
end

params = JSON.parse(STDIN.read)
env    = params['env'] || 'production'

begin
  res = clear_env_cache(env)
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
else
  puts({ responsecode: res.code, responsebody: res.body }.to_json)
  if res.code.to_i == 204
    exit 0
  else
    exit 1
  end
end
