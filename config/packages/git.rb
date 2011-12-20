package :git, :provides => :scm do
  description 'Git Distributed Version Control'
  apt 'git-core' #just use the apt provided one, source link seems to change frequently...

  verify do
    has_executable 'git'
  end
end
