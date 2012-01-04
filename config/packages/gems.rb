# package :gems do
#   
#   ['install: --no-rdoc --no-ri', 'update: --no-rdoc --no-ri'].each do |line|
#     pre :install, "echo '#{line}' | tee -a ~/.gemrc"
#   end
#   
#   %w(rubygems-update bundler rack rails rake).each do |gem_name|
#     description "#{gem_name} (versioned)"
#     gem gem_name, :version => "~>#{eval("VERSION_#{}")}"
#     verify do
#       has_gem gem_name
#     end
#   end
#   
#   #non-similarly named executables to check for
#   verify do
#     has_executable 'bundle'
#     has_executable 'rackup'
#   end
# end

#minimize globablly install gems, most should be installed via bundler locally per project
package :gems, :provides => [:bundler] do
  description 'Bundler, Rake (versioned)'
  
  ['install: --no-rdoc --no-ri', 'update: --no-rdoc --no-ri'].each do |line|
    pre :install, "echo '#{line}' | tee -a ~/.gemrc"
  end
  
  binaries = %w(bundle god)
  binaries.each do |bin| 
    post :install, "sudo ln -s #{RUBY_PATH}/bin/#{bin} /usr/local/bin/#{bin}"
  end
  
  gem 'rubygems-update'
  gem 'bundler'
  #gem 'rack', :version => '~>1.3.5'
  #gem 'rails', :version => '~>3.2.0'
  #gem 'rake', :version => '~>0.9.2.2'
  
  verify do
    has_gem 'bundler'
    has_executable 'bundle'
    # has_gem 'rack'
    # has_executable 'rackup'
    # has_gem 'rails'
    #has_gem 'rake'
  end
  
  requires :rubygems
end

package :god do
  gem 'god'
  
  verify do
    has_executable 'god'
  end
end

package :god_service do
  
  transfer "#{File.dirname(__FILE__)}/../config/god", '/etc/init.d/god', :sudo => true do
    post :install, 'sudo chmod +x /etc/init.d/god'
    post :install, 'sudo update-rc.d god defaults'
    
    post :install, 'sudo mkdir /etc/god'
    post :install, 'sudo touch /var/log/god.log'
  end

  verify do
    has_file '/etc/init.d/god'
  end
  
  requires :god
end