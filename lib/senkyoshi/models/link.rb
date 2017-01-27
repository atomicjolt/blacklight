module Senkyoshi
  ##
  # Represents a link between Blackboard resources.
  ##
  class Link < FileResource
    def self.get_pre_data(xml_data, _file)
      {
        title: xml_data.children.at("TITLE").attributes["value"].value,
        referrer: xml_data.children.at("REFERRER").attributes["id"].value,
        referred_to: xml_data.children.at("REFERREDTO").attributes["id"].value,
      }
    end
  end
end
