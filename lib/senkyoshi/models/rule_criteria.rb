require "senkyoshi"

module Senkyoshi
  class RuleCriteria
    include Senkyoshi
    attr_reader(:id, :negated, :content_id, :asidata_id)

    COMPLETION_TYPES = {
      must_view: "must_view",
      must_submit: "must_submit",
      min_score: "min_score",
      must_contribute: "must_contribute",
    }.freeze

    def initialize(id, negated)
      @id = id
      @negated = negated
    end

    def add_if_unique(collection, item)
      if collection.detect do |collection_item|
           yield(collection_item, item)
         end.nil?
        collection << item
      end
      collection
    end

    def add_to_module_if_unique(items, item)
      add_if_unique(
        items, item
      ) { |a, b| a.identifierref == b.identifierref }
    end

    def self.get_id(xml)
      xml.xpath("./@id").text
    end

    def self.get_negated(xml)
      xml.xpath("./NEGATED/@value").text
    end

    def self.from_xml(xml)
      new(RuleCriteria.get_id(xml), RuleCriteria.get_negated(xml))
    end

    ##
    # Determine two identifierrefs are pointed to by items in the same module
    def self.in_same_module?(modules, content_id, resource_id)
      content_module = Module.find_module_from_item_id(modules, content_id)
      resource_module = Module.find_module_from_item_id(modules, resource_id)
      return nil if content_module.nil? || resource_module.nil?
      !content_module.nil? && content_module == resource_module
    end

    def self.module_prerequisite?(modules, content_id, resource_id)
      in_same_module?(modules, content_id, resource_id) == false
    end

    def self.module_completion_requirement?(modules, content_id, resource_id)
      in_same_module?(modules, content_id, resource_id) == true
    end

    ##
    # Returns the most applicable id. If we have an assignment id return that,
    # otherwise return the content id.
    ##
    def get_id
      @asidata_id || @content_id
    end

    ##
    # Factory method to construct a completion requirement. Should be passed
    # the module that the completion requirement should belong to
    ##
    def make_completion(mod)
      CanvasCc::CanvasCC::Models::ModuleCompletionRequirement.new.tap do |req|
        mod_item = ModuleItem.find_item_from_id_ref(
          mod.module_items, get_foreign_id
        )

        req.identifierref = mod_item.identifier if mod_item
        req.type = get_completion_type
      end
    end

    ##
    # Factory method to construct a module prerequisite. Should be passed the
    # prerequisite module
    ##
    def make_prereq(prereq_module)
      CanvasCc::CanvasCC::Models::ModulePrerequisite.new.tap do |prereq|
        prereq.identifierref = prereq_module.identifier
        prereq.type = "context_module"
      end
    end

    ##
    # Use gradebook to find assignment id if applicable
    ##
    def set_ids(content_id, resources)
      @content_id = content_id
      gradebook = resources.find_instances_of(Gradebook).first
      if gradebook
        outcome_def = gradebook.outcome_definitions.detect do |out_def|
          out_def.content_id == content_id
        end
        @asidata_id = outcome_def.asidataid if outcome_def
      end
    end

    def canvas_conversion(course, content_id, resources)
      set_ids(content_id, resources)

      mod = Module.find_module_from_item_id course.canvas_modules, get_id

      is_completion = RuleCriteria.module_completion_requirement?(
        course.canvas_modules, get_id, get_foreign_id
      )

      is_prereq = RuleCriteria.module_prerequisite?(
        course.canvas_modules, get_id, get_foreign_id
      )

      if is_completion
        add_to_module_if_unique(
          mod.completion_requirements, make_completion(mod)
        )
      elsif is_prereq
        prereq_module = Module.find_module_from_item_id(
          course.canvas_modules, get_foreign_id
        )

        add_to_module_if_unique(
          mod.prerequisites, make_prereq(prereq_module)
        )

        add_to_module_if_unique(
          prereq_module.completion_requirements, make_completion(prereq_module)
        )
      end

      course
    end
  end
end
