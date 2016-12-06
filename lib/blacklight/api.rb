require "httparty"

module Blacklight
  class Api
    include HTTParty

    # Need to make calls to multiple end points
    # Need to keep track of tokens
    # -->  Read from .env file?
    # Should be used by each model

    # def initialize(uri = nil)
    #   self.base_uri uri unless uri.nil?
    # end
  end
end
