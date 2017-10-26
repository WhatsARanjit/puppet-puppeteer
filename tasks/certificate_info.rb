#!/opt/puppetlabs/puppet/bin/ruby
require 'puppet'
Puppet.initialize_settings

class Certinfo

  def initialize
    @cert    = OpenSSL::X509::Certificate.new(File.read Puppet[:hostcert])
    @expires = @cert.not_after
    @output  = ''

    make_output
  end

  attr_reader :expires, :output

  def check_threshold?(t)
    begin
      # Try to parse String into Time object
      check = Time.parse(t)
    rescue ArgumentError => e
      m = t.match(/(\d+)(\w)/)
      raise 'Incorrect threshold value' unless m.length == 3

      num  = m[1].to_i
      unit = m[2]

      case unit
      when 's'
        l = num
      when 'm'
        l = num*60
      when 'h'
        l = num*60*60
      when 'd'
        l = num*60*60*24
      when 'y'
        l = num*60*60*24*365
      else
        raise 'Invalid unit. Please choose from [s,m,h,d,y].'
      end
      check = (Time.now + l)
    end
    late = check >= @expires
    @output['threshold'] = "Expiring before #{t}!" if late
    # Supply exit code so certs in danger are presented as failed
    late ? 2 : 0
  end

  private

  def time_to_expiry(tag=1, display_units=true)
    readable_time(time_left, tag, '', display_units)
  end

  def time_left
    @expires - Time.now
  end

  def readable_time(interval, tag, label='second', display_units)
    # To start
    _interval = interval
    unit      = label
    # Keep minimizing the number until it's a manageable number
    unless interval < 100
      case tag
      when 1
        # sec to min
        _interval = interval/60
        unit      = 'minute'
      when 2
        # min to hr
        _interval = interval/60
        unit      = 'hour'
      when 3
        # hr to day
        _interval = interval/24
        unit      = 'day'
      when 4
        # day to yr
        _interval = interval/365
        unit      = 'year'
      else
        # Bail out with original values
        _interval = interval
        unit      = unit
        skip      = true
      end
      return readable_time(_interval, tag+1, unit) unless skip
    end
    # Don't round a time reported in seconds (raw)
    if display_units
      _interval
    else
      rounded = _interval.round(1)
      rounded == 1 ? "#{rounded} #{unit}" : "#{rounded} #{unit}s"
    end
  end

  def make_output
    ret = {
      'subject' => @cert.subject.to_s.gsub(/^\/CN=/, ''),
      'issuer'  => @cert.issuer.to_s.gsub(/^\/CN=/, ''),
      'serial'  => @cert.serial.to_i,
      'issued'  => @cert.not_before.to_s,
      'expires' => @expires,
      'tte'     => time_to_expiry,
      'tte_raw' => time_to_expiry(5, false),
    }
    @output = ret
  end
end

params = JSON.parse(STDIN.read)
threshold = params['threshold']
failp     = params['fail']
# Testing
#threshold = '5y'
#failp     = 'no_fail'

begin
  exit_code = 0
  cert      = Certinfo.new
  exit_code = cert.check_threshold?(threshold) if threshold
  exit_code = 0 if failp == 'no_fail'
  puts(cert.output.to_json)
  exit exit_code
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
