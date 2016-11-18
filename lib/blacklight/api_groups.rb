require_relative "exceptions"

module Blacklight

  def self.iterate_groups(xml_data, course)
    # can't do with canvas_cc as far as I know might need to do it through the api
    # just storing for now
    values = {}
    id = xml_data.children.at("GROUP").attributes["id"].value
    values[id] = {}
    values[id]["name"] = xml_data.children.at("TITLE").attributes["value"].value
    values[id]["description"] = xml_data.children.at("TEXT").children.text
    values[id]["is_public"] = xml_data.children.at("ISAVAILABLE").attributes["value"].value
    course.add_to_values("groups", values)
  end

  def self.iterate_blog(xml_data, course)
    # this is only supported with 3rd party integration at this point so just storing
    values = {}
    id = xml_data.attributes["id"].value
    values[id] = {}
    values[id]["title"] = xml_data.children.at("TITLE").attributes["value"].value
    values[id]["description"] = xml_data.children.at("TEXT").text
    values[id]["is_public"] = xml_data.children.at("ISAVAILABLE").attributes["value"].value
    course.add_to_values("blogs", values)
  end



end
