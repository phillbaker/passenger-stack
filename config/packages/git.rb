# This setup will allow one to host git repos on the remote server.
# This is useful if, for example, one would like to deploy those apps via capistrano.
#   See (http://fclose.com/b/linux/366/set-up-git-server-through-ssh-connection/)
#    local$ ssh git@[remote]
#    remote$ mkdir /home/git/example.git
#    remote$ cd /home/git/example.git/
#    remote$ git --bare init
#    remote$ exit
#    local$ cd ~/tmp
#    local$ mkdir git_example
#    local$ cd git_example
#    local$ touch README
#    local$ git init
#    local$ git commit -m 'first commit'
#    local$ git remote add origin ssh://git@[remote]/~/example.git
#    local$ git push origin master
#    
#    Clone with:
#    local$ git clone ssh://git@[remote]/~/example.git
#    
#    Add user's ssh public keys to git@[remote]:~/.ssh/authorized_keys to allow sharing/team development.
#    

package :git, :provides => :scm do
  description 'Git Distributed Version Control'
  apt 'git-core' do #just use the apt provided one, source link seems to change frequently...
    # Change the users's default shell to git-shell only. (ie new git repo's/etc. cannot be created using this username)
    # http://stackoverflow.com/questions/7024553/how-to-prevent-interactive-ssh-login/7024592#7024592
    post :install, 'chsh -s `which git-shell` git'
  end

  verify do
    has_executable 'git'
  end
end
