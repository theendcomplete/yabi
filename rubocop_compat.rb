# frozen_string_literal: true

# Shim to keep rubocop-rspec_rails working with RuboCop >= 1.84.
# rubocop-rspec_rails (2.29.1) still calls `inject_defaults!` with a project
# root directory. Newer RuboCop expects a path to a config file instead.
module RuboCop
  class ConfigLoader
    class << self
      alias yabi_original_inject_defaults! inject_defaults!

      def inject_defaults!(path)
        if path && File.directory?(path)
          candidate = File.join(path, 'config', 'default.yml')
          return yabi_original_inject_defaults!(candidate) if File.file?(candidate)
        end

        yabi_original_inject_defaults!(path)
      end
    end
  end
end
