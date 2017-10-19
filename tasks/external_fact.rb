#!/opt/puppetlabs/puppet/bin/ruby
require 'puppet'

class Externalfacts

  def initialize(fact, value, file, remove)
    @fact   = fact
    @value  = value
    @file   = file
    @remove = remove
    @status = 'error'
    @cache  = Hash.new
    @output = ''

    mk_factsd_dirs
    do_fact
  end

  attr_reader :cache, :status, :output

  def do_fact
    @cache  = read_file
    @output = update_status

    adjust_hash
    write_file
  end

  private

  def adjust_hash
    # If remove is specified, remove fact instead of adding
    if @remove
      @cache.delete(@fact)
    else
      @cache[@fact] = @value
    end
  end

  def fact_exist?
    @cache.keys.include?(@fact)
  end

  def update_status
    if fact_exist? or @remove
      @status = 'changed'   if @cache[@fact] != @value
      @status = 'unchanged' if @cache[@fact] == @value
    else
      @status = 'created'
    end
    make_output
  end

  def make_output
    _new = @value.nil?        ? '' : @value
    _old = @cache[@fact].nil? ? '' : @cache[@fact]
    out    = {
      'status'    => @status,
      'old_value' => _old,
      'new_value' => _new,
    }
    case @status
    when 'changed'
      out['message'] = "'#{@fact}' value updated to '#{@value}'."
    when 'created'
      out['message'] ="'#{@fact}' value set to '#{@value}'."
    else
      out['message'] ="'#{@fact}' value is already '#{@value}'."
    end
    out
  end

  def read_file
    ret_hash = Hash.new
    stuff    = File.read(factsd_file)

    case file_ext
    when '.txt'
      stuff.split("\n").each do |line|
        stuff            = line.split('=')
        ret_hash[stuff[0]] = stuff[1].chomp
      end
    when '.json'
      begin
        ret_hash = JSON.parse(stuff)
      rescue JSON::ParserError => e
        ret_hash = Hash.new
      end
    when '.yaml'
      begin
        ret_hash = YAML.load(stuff)
      rescue Psych::SyntaxError => e
        ret_hash = Hash.new
      end
    else
      raise "File type for '#{@file}' is not supported."
    end
    unless ret_hash
      {}
    else
      ret_hash
    end
  end

  def write_file
    case file_ext
    when '.txt'
      new_content = @cache.map { |k,v| "#{k}=#{v}" }.join("\n")
    when '.json'
      new_content = @cache.to_json
    when '.yaml'
      new_content = @cache.to_yaml
    else
      raise "File type for '#{@file}' is not supported."
    end
    if @cache == {}
      File.delete(factsd_file)             # remove empty file
    else
      File.write(factsd_file, new_content) # write file
    end
  end

  def file_ext
    File.extname(@file)
  end

  def mk_factsd_dirs
    Dir.mkdir(facter_dir) unless File.exist?(facter_dir)
    Dir.mkdir(factsd_dir) unless File.exist?(factsd_dir)
    File.open(factsd_file, 'w') {} unless File.exist?(factsd_file)
  end

  def facter_dir
    if Puppet.features.root? && !Puppet::Util::Platform.windows?
      '/etc/puppetlabs/facter'
    else
      'C:\ProgramData\PuppetLabs\facter'
    end
  end

  def factsd_dir
    "#{facter_dir}/facts.d"
  end

  def factsd_file
    "#{factsd_dir}/#{@file}"
  end
end

params = JSON.parse(STDIN.read)
# For testing
#params = {
#  'fact'   => ARGV[0],
#  'value'  => ARGV[1],
#  'file'   => "#{ARGV[0]}.yaml",
#  'remove' => true,
#}
fact   = params['fact']
value  = params['value']
file   = params['file']   || "#{fact}.txt"
remove = params['remove'] || false

raise 'Incorrect arguments provided' unless (
  ( fact and !value and remove ) or # remove a value
  ( fact and value and !remove )    # add a value
)

begin
  extfact = Externalfacts.new(fact, value, file, remove)
  puts(extfact.output.to_json)
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
