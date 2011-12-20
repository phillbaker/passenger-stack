package :mongodb, :provides => :database do
  description 'Mongo Database'
  apt %w( mongodb )
  
  verify do
    has_executable 'mongo'
  end

end