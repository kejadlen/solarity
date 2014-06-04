require 'util'

module Solarity

  module Camera

    module_function

    # @param path [String] where to save the image.
    def take_photo(path)
      Util.check_for_dependency(CONFIG['camera_cmd'])
      cmd = CONFIG['camera_cmd']
      args = (CONFIG['camera_cmd_args'] % { path: path })
      %x(#{ cmd } #{ args })
    end

  end

end
