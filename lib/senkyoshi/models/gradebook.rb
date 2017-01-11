require "byebug"
require "senkyoshi/models/outcome_definition"
require "senkyoshi/models/resource"

module Senkyoshi
  class Gradebook < Resource
    attr_accessor(:outcome_definitions)

    def iterate_xml(xml_data, _)
      @categories = Gradebook.get_categories(xml_data)
      @outcome_definitions = get_outcome_definitions(xml_data).compact
      self
    end

    def self.get_pre_data(data, _)
      categories = get_categories(data)
      data.search("OUTCOMEDEFINITIONS").children.map do |outcome|
        category_id = outcome.at("CATEGORYID").attributes["value"].value
        {
          category: categories[category_id],
          points: outcome.at("POINTSPOSSIBLE").attributes["value"].value,
          content_id: outcome.at("CONTENTID").attributes["value"].value,
          assignment_id: outcome.at("ASIDATAID").attributes["value"].value,
          due_at: outcome.at("DUE").attributes["value"].value,
        }
      end
    end

    def self.get_categories(data)
      data.at("CATEGORIES").children.
        each_with_object({}) do |category, categories|
        id = category.attributes["id"].value
        title = category.at("TITLE").
          attributes["value"].value.gsub(".name", "")
        categories[id] = title
      end
    end

    def get_outcome_definitions(xml)
      xml.xpath("//OUTCOMEDEFINITION").map do |outcome_definition|
        user_created = outcome_definition.xpath("ISUSERCREATED/@value").first.value
        if user_created == "true"
          category_id = outcome_definition.xpath("CATEGORYID/@value").first.value
          category = @categories[category_id]
          OutcomeDefinition.from(outcome_definition, category)
        end
      end
    end

    def canvas_conversion(course, _ = nil)
      # Convert all outcome definitions to assignments
      @outcome_definitions.
        select { |outcome_def| outcome_def.content_id.empty? }.
        each { |outcome_def| outcome_def.canvas_conversion course, _ }
      course
    end
  end
end
