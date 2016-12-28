require "senkyoshi/models/question"

module Senkyoshi
  class HotSpot < Question
    def iterate_xml(data)
      super
      @material = "#{@title} -- This question was imported from an
        external source. It was a #{@blackboard_type} question, which
        is not supported in this quiz tool."
      self
    end
  end
end
