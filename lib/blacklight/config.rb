require "yaml"

module Blacklight
  def self.canvas_url
    Blacklight._config[:canvas_url]
  end

  def self.canvas_token
    Blacklight._config[:canvas_token]
  end

  def self.scorm_launch_url
    Blacklight._config[:scorm_launch_url]
  end

  def self.scorm_url
    Blacklight._config[:scorm_url]
  end

  def self._config
    @config ||= if File.exists? "blacklight.yml"
                  YAML::load(File.read("blacklight.yml"))
                else
                  {}
                end
  end
end
