require "yaml"

module Senkyoshi
  class Configuration
    attr_accessor :canvas_url
    attr_accessor :canvas_token
    attr_accessor :account_id
    attr_accessor :scorm_url
    attr_accessor :scorm_launch_url
    attr_accessor :scorm_shared_auth

    def initialize
      @canvas_url = Configuration._config[:canvas_url]
      @canvas_token = Configuration._config[:canvas_token]
      @account_id = Configuration._config[:account_id] || :self
      @scorm_url = Configuration._config[:scorm_url]
      @scorm_launch_url = Configuration._config[:scorm_launch_url]
      @scorm_shared_auth = Configuration._config[:scorm_shared_auth]
    end

    def self._config
      @config ||= if File.exists? "senkyoshi.yml"
                    YAML::load(File.read("senkyoshi.yml"))
                  else
                    {}
                  end
    end
  end
end
