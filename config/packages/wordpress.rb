package :wordpress do
  description 'Latest version of wordpress'
  
  
  binary 'http://wordpress.org/latest.tar.gz' do
    #directory we extract to, if it's not set and we invoke this package, store it in /tmp
    prefix "/var/www/#{Package.fetch(:wordpress)}" || '/tmp'
  end
  
  #allow multiple copies? ['labs.example.com', 'blog.example.com']
  # wp_installs = [*Package.fetch(:wordpress)]; 
  # prefix '/tmp'
  # wp_installs.each {|wp| post :install, "sudo cp -r /tmp/latest /var/www/#{wp}"}
  requires :php
end