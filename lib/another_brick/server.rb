module AnotherBrick
  module Server
    extend self

    def deploy(tag)
      Net::SSH.start AnotherBrick.deploy_server, AnotherBrick.deploy_user do |ssh|
        AnotherBrick.max_tries.times do
          exec(ssh, "apt-get update")
          cache_show = exec(ssh, "apt-cache show #{AnotherBrick.package_name}")
          version = tag.split('_')[1]

          unless cache_show =~ /#{AnotherBrick.package_name}_#{version}_(.*)\.deb/
            sleep 2
            next
          end

          exec(ssh, "apt-get install --force-yes -y #{AnotherBrick.package_name}")
          break
        end
      end
    end

    def exec(ssh, command)
      ssh.exec!(command).tap do |result|
        return result unless AnotherBrick.verbose?
        puts command
        puts result
      end
    end
  end
end
