module AnotherBrick
  module Tag
    extend self

    PREFIXES = %w(unstable stable testing)
    TAG_RE   = /^(#{PREFIXES.map {|p| "#{p}"}.join("|") })(?:_(\d+.\d+.\d+))?$/

    def create(tag)
      build_tag(tag).tap do |next_tag|
        `git tag #{next_tag}`
        `git push --tags`
      end
    end

    def build_tag(tag)
      captures = TAG_RE.match(tag).captures

      if captures[1]
        tag
      else
        major, minor, build = last_tag ? strip_version(last_tag) : [0, 0, 0]

        "#{captures[0]}_#{major}.#{minor}.#{build.to_i + 1}"
      end
    end

    def version_sorter
      proc do |v1, v2|
        Gem::Version.new(v1) <=> Gem::Version.new(v2)
      end
    end

    def last_tag
      prefix_re = /(?:v|#{PREFIXES.map { |e| "#{e}_" }.join("|") })(\d+\.\d+(?:\.\d+)?)/
      `git tag `.lines.map(&:chomp).select { |e| e =~ prefix_re }.map do |line|
        line.gsub(prefix_re, "\\1")
      end.sort(&version_sorter).last
    end

    def strip_version(version)
      version.split('.').map(&:to_i).tap do |v|
        v[2] ||= -1
      end
    end
  end
end
