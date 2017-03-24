module CapistranoChewy
  def self.gem_version
    Gem::Version.new VERSION::STRING
  end

  module VERSION
    MAJOR = 0
    MINOR = 2
    TINY = 2

    STRING = [MAJOR, MINOR, TINY].compact.join('.')
  end
end
