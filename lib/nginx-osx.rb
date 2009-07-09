class NginxOsx
  
  def execute(cmd)
    if respond_to?(cmd.to_sym)
      self.send(cmd.to_sym) 
    else
      help
    end
  end
  
  def help
    usage = <<-'USAGE'
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
    require 'open-uri'
    config = open('http://gist.github.com/raw/15892/b29439a05d44cd6f2d9913f27674752bcc6ea7fc/nginx.conf').read
    File.open('/opt/local/etc/nginx/nginx.conf', 'w+') do |f|
     f.puts config
    end
    `mkdir -p /opt/local/conf/vhosts`
    `mkdir -p /opt/local/conf/configs`
    `sudo /opt/local/sbin/nginx -t`
  end

  def add
    require 'open-uri'
    require 'erb'
    port = ENV['PORT'] || '3000'
    config = open('http://gist.github.com/raw/16312/5baa900cd46b278adf5ee6ba667ae46a7571483a/nginx.vhost.conf').read
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