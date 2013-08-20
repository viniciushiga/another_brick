module AnotherBrick
  module Configuration
    attr_accessor :bricklayer_server, :package_name, :deploy_server,
                  :deploy_user, :max_tries, :bricklayer_tries, :tag

    def load_configuration(options = {})
      self.bricklayer_server = options[:bricklayer]
      self.package_name      = options[:name]
      self.deploy_server     = options[:server]
      self.deploy_user       = options[:user]
      self.max_tries         = options[:max_tries]
      self.bricklayer_tries  = options[:bricklayer_tries]
      self.tag               = options[:tag]
      @verbose               = options[:verbose]
      RestClient.proxy       = ENV['http_proxy']
    end

    def verbose?
      @verbose
    end
  end
end
