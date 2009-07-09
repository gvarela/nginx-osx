require 'open-uri'
require 'erb'

class NginxOsx
  TEMPLATES_DIR = File.join(File.dirname(__FILE__), '../', 'templates')
  
  def initialize(args)
    cmd = args.is_a?(Array) ? args[0] : args
    if cmd && respond_to?(cmd.to_sym)
      self.send(cmd.to_sym) 
    else
      help
    end
  end
  
  def help
    usage = <<-'USAGE'
USAGE:
  nginx-osx [cmd]
    
    install
      - install nginx via macports
    setup
      - setup the basic nginx.conf file and the vhost directories
    add
      - add the current directory as a vhost
    run
      - run the current directory as the default vhost (symlinks in the vhost)
    start
      - start nginx
    stop
      - stop nginx
    restart
      - restart and check the config for errors
    reload
      - reload the config and check for errors
    USAGE
    puts usage
  end

  def install
  `sudo port install nginx`
  end

  def setup
    config = ''
    File.open(File.join(TEMPLATES_DIR, 'nginx.conf.erb')) do |f|
      config = f.read
    end
    File.open('/opt/local/etc/nginx/nginx.conf', 'w+') do |f|
     f.puts ERB.new(config).result(binding)
    end
    `mkdir -p /opt/local/conf/vhosts`
    `mkdir -p /opt/local/conf/configs`
    `sudo /opt/local/sbin/nginx -t`
  end

  def add
    port = ENV['PORT'] || '3000'
    config = ''
    File.open(File.join(TEMPLATES_DIR, 'nginx.conf.erb')) do |f|
      config = f.read
    end
    filename = Dir.pwd.downcase.gsub(/^\//,'').gsub(/\.|\/|\s/,'-')
    File.open("/opt/local/conf/configs/#{filename}.conf", 'w+') do |f|
     f.puts ERB.new(config).result(binding)
    end
  end

  def run
    filename = Dir.pwd.downcase.gsub(/^\//,'').gsub(/\.|\/|\s/,'-')
    `sudo ln -fs /opt/local/conf/configs/#{filename}.conf /opt/local/conf/vhosts/current.conf`
    `sudo /opt/local/sbin/nginx -t`
    `sudo /opt/local/sbin/nginx`
  end

  def start
    `sudo /opt/local/sbin/nginx`
  end

  def stop
    `sudo killall nginx`
  end

  def restart
    `sudo killall nginx`
    `sudo /opt/local/sbin/nginx -t`
    `sudo /opt/local/sbin/nginx`
  end

  def reload
    `sudo /opt/local/sbin/nginx -t`
    pid = `ps ax | grep 'nginx: master' | grep -v grep | awk '{print $1}'`
    `sudo kill -HUP #{pid}` if pid
  end
end