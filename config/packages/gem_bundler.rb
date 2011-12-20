package :bundler do
  description 'Bundler'
  
  ['install: --no-rdoc --no-ri', 'update: --no-rdoc --no-ri'].each do |line|
    pre :install, "echo '#{line}' | tee -a ~/.gemrc"
  end
  
  gem 'update --system'
  gem 'bundler'

  requires :ruby
end