module Blacklight
  class Gradebook
    attr_reader :outcomes

    def iterate_xml(data)
      @outcomes = get_outcome(data)
      self
    end

    def canvas_conversion(course)
      course
    end

    def get_categories(data)
      categories = {}
      data.at("CATEGORIES").children.each do |category|
        id = category.attributes["id"].value
        title = category.at("TITLE").
          attributes["value"].value.gsub(".name", "")
        categories[id] = title
      end
      categories
    end

    def get_outcome(data)
      outcomes = {}
      categories = get_categories(data)
      data.search("OUTCOMEDEFINITIONS").children.each do |outcome|
        id = outcome.at("CONTENTID").attributes["value"].value
        if id.empty?
          category_id = outcome.at("CATEGORYID").attributes["value"].value
          category = categories[category_id]
          points = outcome.at("POINTSPOSSIBLE").attributes["value"].value
          outcomes[id] = { category: category, points: points }
        end
      end
      outcomes
    end
  end
end
