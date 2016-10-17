# Ensure deploy tasks are loaded before we run
require 'capistrano/deploy'

load File.expand_path('../tasks/chewy.rake', __FILE__)

module CapistranoChewy
  class DiffParser
    class Result
      attr_reader :removed, :changed, :new

      def initialize
        @removed = []
        @changed = []
        @new = []
      end
    end

    class << self
      def parse(diff, source_path, target_path)
        raise ArgumentError, 'source_path can not be the same as target_path!' if source_path == target_path

        diff.split("\n").each_with_object(Result.new) do |line, result|
          # File was changed
          /Files\s+.+\s+and\s+(.+)\s+differ/i.match(line) do |match|
            result.changed << match[1]
            next
          end

          # File was removed
          /Only in (#{Regexp.quote(source_path)}):\s+(.+)/i.match(line) do |match|
            result.removed << File.join(match[1], match[2])
            next
          end

          # New file
          /Only in (#{Regexp.quote(target_path)}):\s+(.+)/i.match(line) do |match|
            result.new << File.join(match[1], match[2])
            next
          end
        end
      end
    end
  end
end
