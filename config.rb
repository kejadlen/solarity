module Solarity

  require 'yaml'

  class Config

    SHARED_CONFIG_PATH = 'config/solarity.yml'

    def initialize
      @config = YAML.load_file(SHARED_CONFIG_PATH) || {}
      env_config_path = "config/#{ ENV['ENV'] }/solarity.yml"
      if File.exists?(env_config_path)
        @config.merge!(YAML.load_file(env_config_path) || {})
        puts "Using config file: #{ env_config_path }"
      end
    end

    def [](key)
      @config[key]
    end

  end

end
