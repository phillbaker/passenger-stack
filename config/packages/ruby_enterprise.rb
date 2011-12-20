package :ruby_enterprise, :provides => :ruby do
  description 'Ruby Enterprise Edition'
  version '1.8.7-2011.03'
  RUBY_PATH = "/usr/local/ruby-enterprise"
  binaries = %w(erb gem irb rackup rails rake rdoc ree-version ri ruby testrb)
  source "http://rubyenterpriseedition.googlecode.com/files/ruby-enterprise-#{version}.tar.gz" do
    custom_install 'sudo ./installer --auto=/usr/local/ruby-enterprise'
    binaries.each {|bin| post :install, "sudo ln -s #{RUBY_PATH}/bin/#{bin} /usr/local/bin/#{bin}" }
  end

  verify do
    has_directory RUBY_PATH
    has_executable "#{RUBY_PATH}/bin/ruby"
    binaries.each {|bin| has_symlink "/usr/local/bin/#{bin}", "#{RUBY_PATH}/bin/#{bin}" }
  end

  requires :ree_dependencies
end

package :ree_dependencies do
  apt %w(zlib1g-dev libreadline5-dev libssl-dev libxslt-dev libxml2-dev)
  requires :build_essential
end