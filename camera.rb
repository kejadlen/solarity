module Solarity

  module Camera

    module_function

    # @param path [String] where to save the image.
    def take_photo(path)
      check_for_dependency(CONFIG['camera_cmd'])
      cmd = CONFIG['camera_cmd']
      args = (CONFIG['camera_cmd_args'] % { path: path } )
      %x(#{ cmd } #{ args }; open #{ path })
    end

    def check_for_dependency(program)
      %x(which #{ program })
      raise "Camera function depends on '#{ program }', which is not installed" unless $? == 0
    end

  end

end
