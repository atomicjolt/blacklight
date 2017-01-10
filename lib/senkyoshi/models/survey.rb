require "senkyoshi/models/qti"

module Senkyoshi
  class Survey < QTI
    def iterate_xml(data, pre_data)
      @quiz_type = "graded_survey"
      super
    end
  end
end
