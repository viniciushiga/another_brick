require "slop"
require "json"
require "rest_client"
require "net/ssh"

require "another_brick/configuration"
require "another_brick/bricklayer"
require "another_brick/testing_tag"
require "another_brick/server"
require "another_brick/version"

module AnotherBrick
  extend self
  extend Configuration

  def run!(options = {})
    load_configuration(options)
    TestingTag.create.tap do |testing_tag|
      Bricklayer.wait_build(testing_tag)
      Server.deploy(testing_tag)
    end
  end
end
