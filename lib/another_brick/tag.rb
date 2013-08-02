module AnotherBrick
  module Tag
    extend self

    def create(prefix)
      version_tag = get_last_tag('v')

      major, minor = strip_version('v', version_tag)

      last_tag = get_last_tag("#{prefix}_#{major}.#{minor}")

      build = last_tag ? strip_version("#{prefix}_", last_tag).last + 1 : 0

      "#{prefix}_#{major}.#{minor}.#{build}".tap do |next_tag|
        `git tag #{next_tag}`
        `git push --tags`
      end
    end

    def get_last_tag(pattern)
      `git tag | grep ^#{pattern} | sort -V`.lines.map(&:chomp).last
    end

    def strip_version(prefix, version)
      version.delete(prefix).split('.').map(&:to_i)
    end
  end
end
