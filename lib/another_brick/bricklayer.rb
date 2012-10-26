module AnotherBrick
  module Bricklayer
    extend self
    SUCCESS = %r{^dpkg-buildpackage: full upload; Debian-native package \(full source is included\)}
    ERROR   = %r{^dpkg-buildpackage: error:}

    def wait_build(tag)
      abort "build not succeeded" unless succeeded? build(tag, project(tag))
    end

    def succeeded?(build)
      result = ""

      AnotherBrick.bricklayer_tries.times do
        result = RestClient.get(log_uri % build).lines.to_a.last
        break if result =~ SUCCESS or result =~ ERROR
        sleep 2
      end

      puts result if AnotherBrick.verbose?
      result =~ SUCCESS
    end

    def project(tag)
      project = nil

      AnotherBrick.bricklayer_tries.times do
        project = JSON.parse RestClient.get(project_uri)
        puts "project_: #{project}" if AnotherBrick.verbose?
        break if project["last_tag_testing"] == tag
        project = nil
        sleep 5
      end

      abort "tag not built" unless project
      puts "project: #{project}" if AnotherBrick.verbose?
      project
    end

    def build(tag, project)
      build = nil
      done = false

      AnotherBrick.bricklayer_tries.times do
        builds = JSON.parse RestClient.get(build_uri)

        builds.reverse.each do |item|
          done = item["version"] == tag.split('_')[1]
          build = item if done
          break if done
        end

        break if done
        sleep 2
      end

      abort "build not found for tag #{tag}" unless done
      puts "build: #{build}" if AnotherBrick.verbose?
      build["build"]
    end

    def base_uri
      "#{AnotherBrick.bricklayer_server}/%s/#{AnotherBrick.package_name}"
    end

    def project_uri
      (base_uri % "project").tap do |uri|
        puts "project_uri: #{uri}" if AnotherBrick.verbose?
      end
    end

    def build_uri
      (base_uri % "build").tap do |uri|
        puts "build_uri: #{uri}" if AnotherBrick.verbose?
      end
    end

    def log_uri
      ("#{base_uri % "log"}/%s").tap do |uri|
        puts "log_uri: #{uri}" if AnotherBrick.verbose?
      end
    end
  end
end
