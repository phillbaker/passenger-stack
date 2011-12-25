package :gems, :provides => [:bundler, :rack, :rails, :rake] do
  description 'Bundler, Rack, Rails, Rake (versioned)'
  
  ['install: --no-rdoc --no-ri', 'update: --no-rdoc --no-ri'].each do |line|
    pre :install, "echo '#{line}' | tee -a ~/.gemrc"
  end
  
  gem 'rubygems-update'
  gem 'bundler'
  gem 'rack', :version => '~>1.3.5'
  gem 'rails', :version => '~>3.2.0'
  gem 'rake', :version => '~>0.9.2.2'
  
  verify do
    has_gem 'bundler'
    has_executable 'bundle'
    has_gem 'rack'
    has_executable 'rackup'
    has_gem 'rails'
    has_gem 'rake'
  end
  
  requires :rubygems
end