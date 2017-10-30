#!/opt/puppetlabs/puppet/bin/ruby
require 'puppet'
Puppet.initialize_settings

Puppet::Type.newtype(:puppeteer_config) do
  ensurable
  newparam(:name, :namevar => true) do
    newvalues(/\S+\/\S+/)
  end
  newproperty(:value) do
    munge do |v|
      v.to_s.strip
    end
  end
end

Puppet::Type.type(:puppeteer_config).provide(
  :pe_ini_setting,
  :parent => Puppet::Type.type(:pe_ini_setting).provider(:ruby)
) do
  def section
    resource[:name].split('/', 2).first
  end
  def setting
    resource[:name].split('/', 2).last
  end
  # hard code the file path (this allows purging)
  def self.file_path
    Puppet.settings[:config]
  end
end

class Puppeteerconfig

  def initialize(setting, value, section, noop=false)
    @setting = setting
    @value   = value
    @section = section
    @noop    = noop
  end

  attr_reader :setting, :value, :section, :noop

  def do_config
    require 'puppet/face'
    if value
      my_resource = Puppet::Resource.new(
        :puppeteer_config,
        "#{section}/#{setting}",
        :parameters => {
          :value    => @value,
          :noop     => @noop,
        },
      )
      Puppet::Face[:resource, '0.0.1'].save(my_resource)
    else
      Puppet::Face[:resource, '0.0.1'].find("puppeteer_config/#{section}/#{setting}")
    end
  end

end

#section = 'main'
#setting = 'foo'
#value   = ARGV[0]
#noop    = true
params  = JSON.parse(STDIN.read)
section = params['section'] || 'main'
setting = params['setting']
value   = params['value']   || false
noop    = params['_noop']   || false

begin
  p = Puppeteerconfig.new(setting, value, section, noop)
  if value
    r      = p.do_config.last.to_data_hash
    attrs  = r.dig('resource_statuses', "Puppeteer_config[#{section}/#{setting}]")
    output = attrs

    output['noop'] = noop
  else
    output = p.do_config
  end
  puts(output.to_json)
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
