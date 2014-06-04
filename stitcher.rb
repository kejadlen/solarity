require 'util'

module Solarity

  module Stitcher

    module_function

    def make_video(input_path_pattern, output_path)
      Util.check_for_dependency(CONFIG['stitch_cmd'])

      arg_opts = {
        input_path_pattern: input_path_pattern,
        output_path:        output_path
      }
      cmd = CONFIG['stitch_cmd']
      args = (CONFIG['stitch_cmd_args'] % arg_opts)
      %x(#{ cmd } #{ args })
    end

  end

end
