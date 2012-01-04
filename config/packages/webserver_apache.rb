package :apache, :provides => :webserver do
  description 'Apache2 web server.'
  
  apt 'apache2 apache2.2-common apache2-mpm-prefork apache2-utils libexpat1 ssl-cert libcurl4-openssl-dev' do
    post :install, 'a2enmod rewrite'
    post :install, 'a2enmod vhost_alias'
  end
  
  # Apache default sites v host file, for arbitrary sub-domain names
  vhosts_default = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'assets', 'etc', 'apache2', 'sites-available', 'default'))
  transfer vhosts_default, '/etc/apache2/sites-available/default', :sudo => true do
    post :install, 'a2ensite default' 
    #also, a restart, but later package installations do that (at least as of now...)
  end
  # Apache index.html for a default home screen (not pure default Apache to disguise non-setup state)
  index_default = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'assets', 'var', 'www', 'localhost', 'public', 'index.html'))
  transfer index_default, '/var/www/localhost/index.html', :sudo => true
  
  if Package.exists?(:domain)
    domain = Package.fetch(:domain)
    vhosts_domain = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'assets', 'etc', 'apache2', 'sites-available', 'domain.erb'))
    transfer vhosts_domain, "/etc/apache2/sites-available/#{domain}", :sudo => true, :render => true, :locals => { :domain => domain } do
      post :install, "a2ensite #{domain}"
    end
    index_domain = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'assets', 'var', 'www', 'domain', 'public', 'index.html.erb'))
    transfer index_domain, "/var/www/#{domain}/public/index.html", :sudo => true, :render => true, :locals => { :domain => domain }
  end
  
  verify do
    has_executable '/usr/sbin/apache2'
    file_contains vhosts_default, "Wildcard subdomain"
    has_file '/var/www/localhost/index.html'
    if Package.exists?(:domain)
      domain = Package.fetch(:domain)
      has_file "/etc/apache2/sites-available/#{domain}"
      has_file "/var/www/#{domain}/public/index.html"
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
      post :install, "echo '#{line}' |sudo tee -a /etc/apache2/extras/passenger.conf"
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
