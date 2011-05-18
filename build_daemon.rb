require 'build'
require 'protocol/build.pb'

require 'rubygems'
require 'amqp'

AMQP.start(:host => "victoria.bitbane.com",
           :user => "guest",
           :pass => "guest",
           :vhost => "/") do |conn|
  amq = AMQP::Channel.new
  queue = amq.queue("build")

  queue.subscribe do |msg|
    Build.run_build(BuildRequest.new.parse_from_string(msg).Begin)
  end
end
