package :ruby_mri, :provides => :ruby do
  description 'MRI Ruby'
  version '1.8.7-p352'
  RUBY_PATH = "/usr/local/ruby"
  binaries = %w(erb gem irb rdoc ri ruby testrb)
  source "http://ftp.ruby-lang.org/pub/ruby/1.8/ruby-#{version}.tar.gz" do
    prefix RUBY_PATH
    binaries.each {|bin| post :install, "sudo ln -s #{RUBY_PATH}/bin/#{bin} /usr/local/bin/#{bin}" }
  end
  
  verify do
    has_directory RUBY_PATH
  end

  requires :ruby_mri_dependencies
end

package :ruby_mri_dependencies do
  apt %w(zlib1g-dev libreadline5-dev libssl-dev libxslt-dev libxml2-dev libc6-dev)
  
  requires :build_essential
end

package :rubygems do
  description 'Ruby Gems Package Management System'
  version '1.8.12'
  source "http://production.cf.rubygems.org/rubygems/rubygems-#{version}.tgz" do
    custom_install 'ruby setup.rb'
  end

  requires :ruby

  verify do
    ruby_can_load 'rubygems'
  end
end
