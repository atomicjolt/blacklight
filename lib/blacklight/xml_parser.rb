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

  SCORM_SCHEMA = "adlscorm"
  FILE_BLACK_LIST = [
    "*.dat",
    "glossary",
    "imsmanifest.xml",
    ".bb-package-info",
    ".bb-package-sig",
  ].freeze

  def self.parse_manifest(zip_file, manifest)
    doc = Nokogiri::XML.parse(manifest)
    resources = doc.at("resources")
    iterate_xml(resources, zip_file)
  end

  def self.iterate_xml(resources, zip_file)
    resources_array = resources.children.map do |resource|
      file_name = resource.attributes["file"].value
      if zip_file.find_entry(file_name)
        data_file = Blacklight.open_file(zip_file, file_name)
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

  def self.black_list?(name, type)
    FILE_BLACK_LIST.any? { |black_item| File.fnmatch?(black_item, name) } ||
      type == :directory
  end

  def self.get_files(zipfile)
    zipfile.entries.
      select { |e| !black_list?(e.name, e.ftype) }.
      map { |entry| BlacklightFile.new(entry) }
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

  def self.add_scorm(zip_file)
    find_scorm_manifests(zip_file).map do |manifest|
      ScormPackage.new zip_file, manifest
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
