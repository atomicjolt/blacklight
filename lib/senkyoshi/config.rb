require "yaml"

module Senkyoshi
  def self.canvas_url
    Senkyoshi._config[:canvas_url]
  end

  def self.canvas_token
    Senkyoshi._config[:canvas_token]
  end

  def self.scorm_launch_url
    Senkyoshi._config[:scorm_launch_url]
  end

  def self.scorm_url
    Senkyoshi._config[:scorm_url]
  end

  def self.scorm_shared_auth
    Senkyoshi._config[:scorm_shared_auth]
  end

  def self.account_id
    Senkyoshi._config[:account_id] || :self
  end

  def self._config
    @config ||= if File.exists? "senkyoshi.yml"
                  YAML::load(File.read("senkyoshi.yml"))
                else
                  {}
                end
  end
end
