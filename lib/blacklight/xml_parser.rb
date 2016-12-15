require "require_all"
require_all "lib/blacklight/models/**/*.rb"
require_relative "exceptions"

module Blacklight
  RESOURCE_TYPE = {
    groups: "Group",
    blog: "Blog",
    announcement: "Announcement",
    forum: "Forum",
    course: "Course",
    questestinterop: "Assessment",
    content: "Content",

    # categories: :iterate_categories,
    # itemcategories: :iterate_itemcategories,
    # staffinfo: :iterate_staffinfo,
    # coursemodulepages: :iterate_coursemodulepages,
    # groupcontentlist: :iterate_groupcontentlist,
    # learnrubrics: :iterate_learnrubrics,
    # collabsessions: :iterate_collabsessions,
    # cms_resource_link_list: :iterate_resource_link_list,
    # courserubricassociations: :iterate_courserubricassociations,
    # partentcontextinfo: :iterate_parentcontextinfo,
    # notificationrules: :iterate_notificationrules,
    # wiki: :iterate_wiki,
    # safeassign: :iterate_safeassign,
  }.freeze

  PRE_RESOURCE_TYPE = {
    content: "Content",
    gradebook: "Gradebook",
  }.freeze

  def self.parse_manifest(zip_file, manifest)
    doc = Nokogiri::XML.parse(manifest)
    resources = doc.at("resources")
    iterate_xml(resources, zip_file)
  end

  def self.iterate_xml(resources, zip_file)
    pre_data = pre_iterator(resources, zip_file)

    resources_array = resources.children.map do |resource|
      file_name = resource.attributes["file"].value
      if zip_file.find_entry(file_name)
        data_file = Blacklight.read_file(zip_file, file_name)
        data = Nokogiri::XML.parse(data_file)
        xml_data = data.children.first
        type = xml_data.name.downcase
        if RESOURCE_TYPE[type.to_sym]
          file = file_name.split(".dat")[0]
          single_data = pre_data.find {|d| d[:file_name] == file }
          single_data = pre_data.find {|d| d[:assignment_id] == file } unless single_data

          res_class = Blacklight.const_get RESOURCE_TYPE[type.to_sym]
          if type == "content"
            Content.from(xml_data, single_data)
           else
            resource = res_class.new
            resource.iterate_xml(xml_data, single_data)
          end
        end
      end
    end
    resources_array.flatten - ["", nil]
  end

  def self.pre_iterator(resources, zip_file)
    pre_data = {}
    resources.children.map do |resource|
      file_name = resource.attributes["file"].value
      if zip_file.find_entry(file_name)
        data_file = Blacklight.read_file(zip_file, file_name)
        data = Nokogiri::XML.parse(data_file)
        xml_data = data.children.first
        type = xml_data.name.downcase
        if PRE_RESOURCE_TYPE[type.to_sym]
          res_class = Blacklight.const_get PRE_RESOURCE_TYPE[type.to_sym]
          resource_class = res_class.new
          pre_data[type] = [] if pre_data[type].nil?
          file = file_name.split(".dat")[0]
          pre_data[type].push(resource_class.get_pre_data(xml_data, file))
        end
      end
    end
    connect_content(pre_data)
  end

  def self.connect_content(pre_data)
    pre_data["content"].each do |content|
      gradebook = pre_data["gradebook"].first.find {|g| g[:content_id] == content[:file_name] }
      if gradebook
        content[:points] = gradebook[:points] || ""
        content[:assignment_id] = gradebook[:assignment_id] || ""
      end
    end
    pre_data["content"]
  end

  ##
  # Iterate through course files and create new BlacklightFile for each
  # non-metadata file.
  ##
  def self.iterate_files(zipfile)
    files = zipfile.glob("csfiles/**/**")
    file_names = files.map(&:name)

    files = files.select do |file|
      if File.extname(file.name) == ".xml"
        # Detect and skip metadata files.
        concrete_file = File.join(
          File.dirname(file.name),
          File.basename(file.name, ".xml"),
        )
        !file_names.include?(concrete_file)
      else
        true
      end
    end

    files.map { |file| BlacklightFile.new(file) }
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
