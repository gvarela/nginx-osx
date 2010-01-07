require 'open-uri'
require 'erb'
require 'optparse'

class NginxOsx
  TEMPLATES_DIR = File.join(File.dirname(__FILE__), '../', 'templates')
  attr_accessor :port, :passenger, :host

  def initialize(*args)
    cmd = args.shift
    parse(args)
    if cmd && respond_to?(cmd.to_sym)
      self.send(cmd.to_sym)
    else
      help
    end
  end

  def help
    puts usage
  end

  def install
    cmd = <<-CMD;
git clone git://github.com/crigor/admoolabs-ports.git ports
cd ports/nginx-0.7.64-passenger-2.2.8
sudo port -v install +passenger
cd ../../
rm -rf ports
CMD
    exec cmd
  end

  def setup
    config = ''
    File.open(File.join(TEMPLATES_DIR, 'nginx.conf.erb')) do |f|
      config = f.read
    end
    File.open('/opt/local/etc/nginx/nginx.conf', 'w+') do |f|
      f.puts ERB.new(config).result(binding)
    end
    `mkdir -p /opt/local/etc/nginx/vhosts`
    `mkdir -p /opt/local/etc/nginx/configs`
    `mkdir -p /var/log/nginx`
    `sudo cp /opt/local/etc/nginx/mime.types.example /opt/local/etc/nginx/mime.types`
    `sudo /opt/local/sbin/nginx -t`
  end

  def add
    config = ''
    File.open(File.join(TEMPLATES_DIR, 'nginx.vhost.conf.erb')) do |f|
      config = f.read
    end
    File.open(current_config_path, 'w+') do |f|
      f.puts ERB.new(config).result(binding)
    end
    if host
      `ghost add #{host}`
    end
  end

  def run
    `sudo ln -fs #{current_config_path} /opt/local/etc/nginx/vhosts/current.conf`
    `sudo /opt/local/sbin/nginx -t`
    puts `sudo /opt/local/sbin/nginx`
  end

  def start
    puts `sudo /opt/local/sbin/nginx`
  end

  def stop
    puts `sudo killall nginx`
  end

  def restart
    `sudo killall nginx`
    `sudo /opt/local/sbin/nginx -t`
    puts `sudo /opt/local/sbin/nginx`
  end

  def reload
    `sudo /opt/local/sbin/nginx -t`
    pid = `ps ax | grep 'nginx: master' | grep -v grep | awk '{print $1}'`
    puts `sudo kill -HUP #{pid}` if pid
  end

  def current_config
    puts current_config_path
    exec "cat #{current_config_path}"
  end

  def tail_error_log
    exec "tail -f /var/log/nginx/default.error.log"
  end

  private
  def current_config_name
    Dir.pwd.downcase.gsub(/^\//, '').gsub(/\.|\/|\s/, '-')
  end

  def current_config_path
    passenger && host ? "/opt/local/etc/nginx/vhosts/#{current_config_name}.conf" : "/opt/local/etc/nginx/configs/#{current_config_name}.conf"
  end

  def usage
    File.read(File.join(File.dirname(__FILE__), '../', 'HELP'))
  end

  def parse(args)
    options = {}
    OptionParser.new do |opts|
      opts.banner = usage

      opts.on("-p", "--port PORT", Integer, "Use a specific port (default is 3000)") do |p|
        self.port = p || 3000
      end
      opts.on("-h", "--host HOST",  "Use a hostname instead of default host") do |h|
        self.host = h
      end
      opts.on("--passenger", "Use passenger") do |p|
        self.passenger = true
      end
    end.parse!

  end
end