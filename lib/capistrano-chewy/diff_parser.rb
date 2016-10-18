module CapistranoChewy
  class DiffParser
    class Result
      attr_reader :removed, :changed, :added

      def initialize
        @removed = []
        @changed = []
        @added = []
      end

      def empty?
        [@removed, @changed, @added].all?(&:empty?)
      end
    end

    CHANGED_FILE_PATTERN = /Files\s+.+\s+and\s+(.+)\s+differ/i
    NEW_OR_REMOVED_FILE_PATTERN = /Only in (.+):\s+(.+)/i

    class << self
      def parse(diff, current_path, release_path)
        raise ArgumentError, 'current_path can not be the same as release_path!' if current_path == release_path

        diff.split("\n").each_with_object(Result.new) do |line, result|
          # File was changed
          CHANGED_FILE_PATTERN.match(line) do |match|
            result.changed << match[1]
            next
          end

          # File was removed or added
          NEW_OR_REMOVED_FILE_PATTERN.match(line) do |match|
            # if file placed in current path, then it was removed from the release path
            if match[1] == current_path.chomp(File::SEPARATOR)
              result.removed << File.join(match[1], match[2])
            else
              result.added << File.join(match[1], match[2])
            end
          end
        end
      end
    end
  end
end
