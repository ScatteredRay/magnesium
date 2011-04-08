require 'rubygems'
require 'amqp'

require 'build.pb'

GitRepo = "/Users/indy/dev/Idtor"
ProjName = "idtor.xcodeproj"
Target = "Idtor"
ConfigName = "Release"
SDKName = "iphoneos4.3"

AMQP.start(:host => "victoria.bitbane.com",
           :user => "guest",
           :pass => "guest",
           :vhost => "/") do |conn|
  amq = AMQP::Channel.new
  queue = amq.queue("build")

  build_message = BuildBegin.new
  build_message.GitRepo = GitRepo
  build_message.Project = ProjName
  build_message.Target = Target
  build_message.ConfigName = ConfigName
  build_message.SDK = SDKName
  #File.open("Certificate.p12", "r") do |f|
  #  build_message.Certificate = f.read()
  #end
  build_message.Certificate = ""

  str = ''
  build_message.serialize_to_string(str)

  queue.publish(str)

  exit
end