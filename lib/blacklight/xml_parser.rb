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
    # questestinterop: "Assessment",
    content: "Content",

    # categories: :iterate_categories,
    # itemcategories: :iterate_itemcategories,
    # staffinfo: :iterate_staffinfo,
    # coursemodulepages: :iterate_coursemodulepages,
    # groupcontentlist: :iterate_groupcontentlist,
    # learnrubrics: :iterate_learnrubrics,
    # gradebook: :iterate_gradebook,
    # collabsessions: :iterate_collabsessions,
    # link: :iterate_link,
    # cms_resource_link_list: :iterate_resource_link_list,
    # courserubricassociations: :iterate_courserubricassociations,
    # partentcontextinfo: :iterate_parentcontextinfo,
    # notificationrules: :iterate_notificationrules,
    # wiki: :iterate_wiki,
    # safeassign: :iterate_safeassign,
  }.freeze

  def self.parse_manifest(zip_file, manifest)
    doc = Nokogiri::XML.parse(manifest)
    resources = doc.at("resources")
    iterate_xml(resources, zip_file)
  end

  def self.iterate_xml(resources, zip_file)
    resources_array = resources.children.map do |resource|
      file_name = resource.attributes["file"].value
      if zip_file.find_entry(file_name)
        data_file = Blacklight.read_file(zip_file, file_name)
        data = Nokogiri::XML.parse(data_file)
        xml_data = data.children.first
        type = xml_data.name.downcase
        if RESOURCE_TYPE[type.to_sym]
          res_class = Blacklight.const_get RESOURCE_TYPE[type.to_sym]
          resource = res_class.new
          resource.iterate_xml(xml_data)
        end
      end
    end
    resources_array.flatten - ["", nil]
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

  # def self.scorm_manifest?(manifest)
  #   begin
  #     parsed_manifest = nokogiri::xml(manifest.get_input_stream.read)
  #     schema_name = parsed_manifest.
  #       xpath("//xmlns:metadata/xmlns:schema").
  #       text.delete(" ").downcase
  #     return schema_name == scorm_schema
  #   rescue nokogiri::xml::xpath::syntaxerror
  #     false
  #   end
  # end
  #
  # def self.find_scorm_manifests(zip_file)
  #   zip_file.
  #     entries.select do |e|
  #       file.fnmatch("*imsmanifest.xml", e.name) && scorm_manifest?(e)
  #     end
  # end

  # def self.add_scorm(zip_file)
  #   find_scorm_manifests(zip_file).map do |manifest|
  #     ScormPackage.new zip_file, manifest
  #   end
  # end

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
