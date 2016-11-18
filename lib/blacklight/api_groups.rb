require_relative "exceptions"

module Blacklight

  def self.iterate_groups(xml_data, course)
    # can't do with canvas_cc as far as I know might need to do it through the api
    # just storing for now
    values = {}
    data = xml_data.children
    id = data.at("GROUP").attributes["id"].value
    values[id] = {}
    values[id]["name"] = data.at("TITLE").attributes["value"].value
    values[id]["description"] = data.at("TEXT").children.text
    values[id]["is_public"] = data.at("ISAVAILABLE").attributes["value"].value
    course.add_to_values("groups", values)
  end

  def self.iterate_blog(xml_data, course)
    # this is only supported with 3rd party integration at this point so just storing
    values = {}
    id = xml_data.attributes["id"].value
    data = xml_data.children
    values[id] = {}
    values[id]["title"] = data.at("TITLE").attributes["value"].value
    values[id]["description"] = data.at("TEXT").text
    values[id]["is_public"] = data.at("ISAVAILABLE").attributes["value"].value
    course.add_to_values("blogs", values)
  end



end
