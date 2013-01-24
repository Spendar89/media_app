require "redis"
rx = /port.(\d+)/
s = File.read("#{::Rails.root}/config/redis/#{::Rails.env}.conf")
port = rx.match(s)[1]
`redis-server #{::Rails.root}/config/redis/#{::Rails.env}.conf`
res = `ps aux | grep redis-server`
raise "Couldn't start redis" unless res.include?("redis-server") && res.include?("#{::Rails.root}/config/redis/#{::Rails.env}.conf")
$redis = Redis.new(:port => port)