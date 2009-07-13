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
    current_config
      - show vhost config of current directory
    tail_error_log
      - tail the main nginx error log
    USAGE
    puts usage
  end

  def install
  exec "sudo port install nginx"
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
    port = ENV['PORT'] || '3000'
    config = ''
    File.open(File.join(TEMPLATES_DIR, 'nginx.vhost.conf.erb')) do |f|
      config = f.read
    end
    File.open(current_config_path, 'w+') do |f|
     f.puts ERB.new(config).result(binding)
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
      Dir.pwd.downcase.gsub(/^\//,'').gsub(/\.|\/|\s/,'-')
    end
    
    def current_config_path
      "/opt/local/etc/nginx/configs/#{current_config_name}.conf"
    end
end