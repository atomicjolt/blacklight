require "senkyoshi/models/outcome_definition"
require "senkyoshi/models/resource"

module Senkyoshi
  class Gradebook < Resource
    attr_reader(:outcome_definitions, :categories)

    def initialize(categories = [], outcome_definitions = [])
      @categories = categories
      @outcome_definitions = outcome_definitions
    end

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
      xml.xpath("//OUTCOMEDEFINITION").map do |outcome_def|
        category_id = outcome_def.xpath("CATEGORYID/@value").first.value
        OutcomeDefinition.from(outcome_def, @categories[category_id])
      end
    end

    def convert_categories(course)
      @categories.each do |category|
        if AssignmentGroup.find_group(course, category.last).nil?
          course.assignment_groups <<
            AssignmentGroup.create_assignment_group(category.last)
        end
      end
    end

    def canvas_conversion(course, _ = nil)
      convert_categories(course)
      @outcome_definitions.
        select { |outcome_def| OutcomeDefinition.orphan? outcome_def }.
        each { |outcome_def| outcome_def.canvas_conversion course, _ }
      course
    end
  end
end
