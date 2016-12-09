module Blacklight
  class Gradebook
    def iterate_xml(data)
      @categories = get_categories(data)
      @outcomes = get_outcomedef(data)
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

    def get_outcomedef(data)
      outcomes = {}
      data.search("OUTCOMEDEFINITIONS").children.each do |outcome|
        id = outcome.at("CONTENTID").attributes["value"].value
        if id != ""
          category_id = outcome.at("CATEGORYID").attributes["value"].value
          category = @categories[category_id]
          points = outcome.at("POINTSPOSSIBLE").attributes["value"].value
          outcomes[id] = { category: category, points: points }
        end
      end
      outcomes
    end
  end
end
