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
        RestClient.get(log_uri(build)) do |response|
          result = response

          break if response =~ SUCCESS or response =~ ERROR

          sleep 3
        end
      end

      puts result if AnotherBrick.verbose?

      result =~ SUCCESS
    end

    def project(tag)
      project = nil

      AnotherBrick.bricklayer_tries.times do
        RestClient.get(project_uri) do |response|
          project = JSON.parse(response)

          puts "project : #{project}" if AnotherBrick.verbose?

          break if project && project["last_tag_#{AnotherBrick.release}"] == tag

          project = nil

          sleep 3
        end
      end

      abort "tag not built" unless project

      puts "project: #{project}" if AnotherBrick.verbose?

      project
    end

    def build(tag, project)
      new_version = tag.split('_')[1]
      build       = nil
      done        = false

      AnotherBrick.bricklayer_tries.times do
        RestClient.get(build_uri) do |response|
          builds = JSON.parse(response)

          build = builds.find do |item|
            item["release"] == AnotherBrick.release && item["version"] == new_version
          end

          break if build

          sleep 3
        end
      end

      abort "build not found for tag #{tag}" unless build

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

    def log_uri(build)
      ("#{base_uri % "log"}/#{build}").tap do |uri|
        puts "log_uri: #{uri}" if AnotherBrick.verbose?
      end
    end
  end
end
