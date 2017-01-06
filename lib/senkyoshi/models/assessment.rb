require "senkyoshi/models/qti"

module Senkyoshi
  class Assessment < QTI
    def iterate_xml(data, pre_data)
      @quiz_type = "assignment"
      super
    end
  end
end
