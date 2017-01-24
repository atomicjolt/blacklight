require "senkyoshi/models/rule_criteria"

module Senkyoshi
  class ContentReviewedCriteria < RuleCriteria
    attr_reader(:reviewed_content_id)

    def initialize(id, negated, reviewed_content_id)
      super(id, negated)
      @reviewed_content_id = reviewed_content_id
    end

    def self.from_xml(xml)
      id = RuleCriteria.get_id xml
      negated = Senkyoshi.true? RuleCriteria.get_negated(xml)
      reviewed_content_id = xml.xpath("./REVIEWED_CONTENT_ID/@value").text
      ContentReviewedCriteria.new(id, negated, reviewed_content_id)
    end

    def make_completion(mod)
      CanvasCc::CanvasCC::Models::ModuleCompletionRequirement.new.tap do |req|
        mod_item = ModuleItem.find_item_from_id_ref(
          mod.module_items, @reviewed_content_id
        )

        req.identifierref = mod_item.identifier if mod_item
        req.type = COMPLETION_TYPES[:must_view]
      end
    end

    def make_prereq(prereq_module)
      CanvasCc::CanvasCC::Models::ModulePrerequisite.new.tap do |prereq|
        prereq.identifierref = prereq_module.identifier
        prereq.title = "Howdy"
        prereq.type = "context_module"
      end
    end

    # def find_or_create
    # end

    ## TODO move to rule criteria
    ## then users override make_prereq and make_completion
    def canvas_conversion(course, content_id, _resources = nil)
      is_completion = RuleCriteria.module_completion_requirement?(
        course.canvas_modules, content_id, @reviewed_content_id
      )

      is_prereq = RuleCriteria.module_prerequisite?(
        course.canvas_modules, content_id, @reviewed_content_id
      )

      mod = Module.find_module_from_item_id course.canvas_modules, content_id

      if is_completion
        mod.completion_requirements << make_completion(mod)
      elsif is_prereq
        prereq_module = Module.find_module_from_item_id(
          course.canvas_modules, @reviewed_content_id
        )

        mod.prerequisites << make_prereq(prereq_module)
        prereq_module.completion_requirements << make_completion(prereq_module)
      end

      course
    end
  end
end
