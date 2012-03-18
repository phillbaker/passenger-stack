package :apache, :provides => :webserver do
  description 'Apache2 web server.'
  
  apt 'apache2 apache2.2-common apache2-mpm-prefork apache2-utils libexpat1 ssl-cert libcurl4-openssl-dev' do
    post :install, 'a2enmod rewrite'
    post :install, 'a2enmod vhost_alias'
    post :install, 'touch /var/www/index.html'#'if [ -e /var/www/index.html ]; then rm /var/www/index.html; fi' #remove default start page
    post :install, 'rm /var/www/index.html'
  end
  
  # Apache default sites v host file, for arbitrary sub-domain names
  vhosts_default = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'assets', 'apache', 'default'))
  transfer vhosts_default, '/tmp/default' do
    post :install, 'mv /tmp/default /etc/apache2/sites-available/'
    post :install, 'a2ensite default' 
    #also, a restart, but later package installations do that (at least as of now...)
  end
  # Apache index.html for a default home screen (not pure default Apache to disguise non-setup state)
  index_default = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'assets', 'apache', 'index.html'))
  transfer index_default, '/tmp/index.html' do
    #imitate capistrano setup
    post :install, 'mkdir -p /var/www/localhost/releases/0/public'
    post :install, 'mv /tmp/index.html /var/www/localhost/releases/0/public/'
    post :install, 'ln -s /var/www/localhost/releases/0 /var/www/localhost/current'
  end
  
  #so these types of checks won't work because stuff is pre-recorded (before variables in deploy are set) and then executed after deploy is done...
  domain = Package.fetch(:domain)
  if domain
    vhosts_domain = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'assets', 'apache', 'domain.erb'))
    transfer vhosts_domain, "/tmp/#{domain}", :render => true, :locals => { :domain => domain } do
      post :install, "mv /tmp/#{domain} /etc/apache2/sites-available/"
      post :install, "a2ensite #{domain}"
    end
    
    index_domain = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'assets', 'apache', 'index.html.erb'))
    transfer index_domain, "/tmp/index.html", :render => true, :locals => { :domain => domain } do
      post :install, "mkdir -p /var/www/#{domain}/releases/0/public/"
      post :install, "mv /tmp/index.html /var/www/#{domain}/releases/0/public/"
      post :install, "ln -s /var/www/#{domain}/releases/0 /var/www/#{domain}/current"
    end
  end
  
  noop do
    #based on: http://serverfault.com/questions/6895/whats-the-best-way-of-handling-permissions-for-apache2s-user-www-data-in-var
    
    # Change the ownership of everything under /var/www to root:www-pub
    pre :install, 'chown -R root:www-pub /var/www'
    # Change the permissions of all the folders to 2775, recursively
    pre :install, 'find /var/www -type d -exec chmod 2775 {} \;'
    pre :install, 'find /var/www -type f -exec chmod 0664 {} \;'
  end
  
  verify do
    has_executable 'apache2'
    file_contains '/etc/apache2/sites-available/default', "# Wildcard subdomain"
    has_file '/var/www/localhost/current/public/index.html'
    if domain
      has_file "/etc/apache2/sites-available/#{domain}"
      has_file "/var/www/#{domain}/current/public/index.html"
    end
  end
  
  requires :build_essential
  optional :apache_etag_support, :apache_deflate_support, :apache_expires_support
end

package :apache2_prefork_dev do
  description 'A dependency required by some packages.'
  apt 'apache2-prefork-dev'
end

package :passenger, :provides => :appserver do
  description 'Phusion Passenger (mod_rails)'
  version '3.0.11'
  binaries = %w(passenger-config passenger-install-apache2-module passenger-make-enterprisey passenger-memory-stats passenger-spawn-server passenger-status passenger-stress-test)
  
  gem 'passenger' do
    binaries.each {|bin| post :install, "ln -s #{RUBY_PATH}/bin/#{bin} /usr/local/bin/#{bin}"}
    
    post :install, 'echo -en "\n\n\n\n" | sudo passenger-install-apache2-module'

    # Create the passenger conf file
    post :install, 'mkdir -p /etc/apache2/extras'
    post :install, 'touch /etc/apache2/extras/passenger.conf'
    post :install, 'echo "Include /etc/apache2/extras/passenger.conf"|sudo tee -a /etc/apache2/apache2.conf'

    [%Q(LoadModule passenger_module #{RUBY_PATH}/lib/ruby/gems/1.8/gems/passenger-#{version}/ext/apache2/mod_passenger.so),
    %Q(PassengerRoot #{RUBY_PATH}/lib/ruby/gems/1.8/gems/passenger-#{version}),
    %q(PassengerRuby /usr/local/bin/ruby),
    %q(RackEnv production),
    %q(RailsEnv production)].each do |line|
      post :install, "echo '#{line}' | sudo tee -a /etc/apache2/extras/passenger.conf"
    end

    # Restart apache to note changes
    post :install, '/etc/init.d/apache2 restart'
  end

  verify do
    has_file "/etc/apache2/extras/passenger.conf"
    has_file "#{RUBY_PATH}/lib/ruby/gems/1.8/gems/passenger-#{version}/ext/apache2/mod_passenger.so"
    has_directory "#{RUBY_PATH}/lib/ruby/gems/1.8/gems/passenger-#{version}"
  end

  requires :apache, :apache2_prefork_dev, :rubygems
end

# These "installers" are strictly optional, I believe
# that everyone should be doing this to serve sites more quickly.

# Enable ETags
package :apache_etag_support do
  apache_conf = "/etc/apache2/apache2.conf"
  config = <<eol
  # Passenger-stack-etags
  FileETag MTime Size
eol

  push_text config, apache_conf, :sudo => true
  verify { file_contains apache_conf, "Passenger-stack-etags"}
end

# mod_deflate, compress scripts before serving.
package :apache_deflate_support do
  apache_conf = "/etc/apache2/apache2.conf"
  config = <<eol
  # Passenger-stack-deflate
  <IfModule mod_deflate.c>
    # compress content with type html, text, and css
    AddOutputFilterByType DEFLATE text/css text/html text/javascript application/javascript application/x-javascript text/js text/plain text/xml
    <IfModule mod_headers.c>
      # properly handle requests coming from behind proxies
      Header append Vary User-Agent
    </IfModule>
  </IfModule>
eol

  push_text config, apache_conf, :sudo => true
  verify { file_contains apache_conf, "Passenger-stack-deflate"}
end

# mod_expires, add long expiry headers to css, js and image files
package :apache_expires_support do
  apache_conf = "/etc/apache2/apache2.conf"

  config = <<eol
  # Passenger-stack-expires
  <IfModule mod_expires.c>
    <FilesMatch "\.(jpg|gif|png|css|js)$">
         ExpiresActive on
         ExpiresDefault "access plus 1 year"
     </FilesMatch>
  </IfModule>
eol

  push_text config, apache_conf, :sudo => true
  verify { file_contains apache_conf, "Passenger-stack-expires"}
end
