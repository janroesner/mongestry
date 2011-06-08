Mongoid.configure do |config|
 config.master = Mongo::Connection.new('localhost', 27017).db('mongestry_test')
end
