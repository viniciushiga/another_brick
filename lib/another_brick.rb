require "slop"
require "json"
require "rest_client"
require "net/ssh"

require "another_brick/configuration"
require "another_brick/bricklayer"
require "another_brick/tag"
require "another_brick/server"
require "another_brick/version"

module AnotherBrick
  extend self
  extend Configuration

  def run!(options = {})
    load_configuration(options)

    Tag.create(tag).tap do |new_tag|
      Bricklayer.wait_build(new_tag) if bricklayer_server && package_name
      Server.deploy(new_tag) if deploy_server && deploy_user
    end
  end

  def release
    tag.split('_')[0]
  end
end
