module Solarity

  module Util

    module_function

    # @param program [String] Raises an error if program is not installed.
    def check_for_dependency(program)
      %x(which #{ program })
      unless $? == 0
        raise "Dependency '#{ program }' is not installed."
      end
    end

  end

end
