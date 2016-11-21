require_relative "exceptions"

module Blacklight
  FUNCTION_TYPE_CALL = {
    course: :iterate_course,
    groups: :iterate_groups,
    blog: :iterate_blog,
    announcement: :iterate_announcement,
    forum: :iterate_forum,

    # categories: :iterate_categories,
    # itemcategories: :iterate_itemcategories,
    # questestinterop: :iterate_questestinterop,
    # staffinfo: :iterate_staffinfo,
    # coursemodulepages: :iterate_coursemodulepages,
    # content: :iterate_content,
    # groupcontentlist: :iterate_groupcontentlist,
    # learnrubrics: :iterate_learnrubrics,
    # gradebook: :iterate_gradebook,
    # courseassessment: :iterate_courseassessment,
    # collabsessions: :iterate_collabsessions,
    # link: :iterate_link,
    # cms_resource_link_list: :iterate_resource_link_list,
    # courserubricassociations: :iterate_courserubricassociations,
    # partentcontextinfo: :iterate_parentcontextinfo,
    # notificationrules: :iterate_notificationrules,
    # wiki: :iterate_wiki,
    # safeassign: :iterate_safeassign,
  }.freeze

  def self.parse_manifest(manifest, course)
    doc = Nokogiri::XML.parse(manifest)
    resources = doc.xpath("//*[resource]")
    iterate_xml(resources, course)
  end

  def self.iterate_xml(resources, course)
    resources[0].children.each do |resource|
      file_name = resource.attributes["file"].value
      data_file = course.open_file(file_name)
      data = Nokogiri::XML.parse(data_file)
      xml_data = data.children.first
      type = xml_data.name.downcase
      if FUNCTION_TYPE_CALL[type.to_sym]
        Blacklight.send(FUNCTION_TYPE_CALL[type.to_sym], xml_data, course)
      end
    end
  end

  def self.create_random_hex
    SecureRandom.hex
  end

  def self.get_attribute_value(xml_data, type)
    value = ""
    if xml_data.children.at(type).attributes["value"]
      value = xml_data.children.at(type).attributes["value"].value
    end
    value
  end

  def self.get_text(xml_data, type)
    value = ""
    if xml_data.children.at(type)
      value = xml_data.children.at(type).text
    end
    value
  end

  def self.get_description(xml_data)
    value = ""
    if xml_data.children.at("DESCRIPTION")
      value = xml_data.children.at("DESCRIPTION").text
    end
    value
  end
end
