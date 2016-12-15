module Blacklight
  class Gradebook
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

    def get_pre_data(data, _)
      categories = get_categories(data)
      outcomes = data.search("OUTCOMEDEFINITIONS").children.map do |outcome|
        content_id = outcome.at("CONTENTID").attributes["value"].value
        assignment_id = outcome.at("ASIDATAID").attributes["value"].value
        category_id = outcome.at("CATEGORYID").attributes["value"].value
        category = categories[category_id]
        points = outcome.at("POINTSPOSSIBLE").attributes["value"].value
        { category: category, points: points, content_id: content_id,
          assignment_id: assignment_id }
      end
      outcomes
    end
  end
end
