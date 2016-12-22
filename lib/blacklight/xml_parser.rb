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
    staffinfo: "StaffInfo",
  }.freeze

  PRE_RESOURCE_TYPE = {
    content: "Content",
    gradebook: "Gradebook",
  }.freeze

  def self.parse_manifest(zip_file, manifest)
    doc = Nokogiri::XML.parse(manifest)
    resources = doc.at("resources")
    iterate_xml(resources, zip_file).flatten - ["", nil]
  end

  def self.iterate_xml(resources, zip_file)
    pre_data = pre_iterator(resources, zip_file)
    iterator_master(resources, zip_file) do |xml_data, type, file|
      if RESOURCE_TYPE[type.to_sym]
        single_pre_data = get_single_pre_data(pre_data, file)
        res_class = Blacklight.const_get RESOURCE_TYPE[type.to_sym]
        if type == "content"
          Content.from(xml_data, single_pre_data)
        else
          resource = res_class.new
          resource.iterate_xml(xml_data, single_pre_data)
        end
      end
    end
  end

  def self.get_single_pre_data(pre_data, file)
    pre_data.detect do |d|
      d[:file_name] == file || d[:assignment_id] == file
    end
  end

  def self.iterator_master(resources, zip_file)
    resources.children.map do |resource|
      file_name = resource.attributes["file"].value
      file = File.basename(file_name, ".dat")
      if zip_file.find_entry(file_name)
        data_file = Blacklight.read_file(zip_file, file_name)
        xml_data = Nokogiri::XML.parse(data_file).children.first
        type = xml_data.name.downcase
        yield xml_data, type, file
      end
    end
  end

  def self.pre_iterator(resources, zip_file)
    pre_data = {}
    iterator_master(resources, zip_file) do |xml_data, type, file|
      if PRE_RESOURCE_TYPE[type.to_sym]
        res_class = Blacklight.const_get PRE_RESOURCE_TYPE[type.to_sym]
        resource_class = res_class.new
        pre_data[type] ||= []
        pre_data[type].push(resource_class.get_pre_data(xml_data, file))
      end
    end
    pre_data = connect_content(pre_data)
    build_heirarchy(pre_data)
  end

  def self.connect_content(pre_data)
    pre_data["content"].each do |content|
      gradebook = pre_data["gradebook"].first.
        detect { |g| g[:content_id] == content[:file_name] }
      if gradebook
        content[:points] = gradebook[:points] || ""
        content[:assignment_id] = gradebook[:assignment_id] || ""
      end
    end
    pre_data["content"]
  end

  def self.build_heirarchy(pre_data)
    parents_ids = pre_data.
      select { |p| p[:parent_id] == "{unset id}" }.
      map { |u| u[:id] }
    pre_data.each do |content|
      next if parents_ids.include?(content[:id])
      next if parents_ids.include?(content[:parent_id])
      parent_id = get_master_parent(pre_data, parents_ids,
                                    content[:parent_id])
      content[:parent_id] = parent_id
    end
  end

  def self.get_master_parent(pre_data, parents_ids, parent_id)
    parent = pre_data.detect { |p| p[:id] == parent_id }
    if parents_ids.include? parent[:id]
      parent[:id]
    else
      get_master_parent(pre_data, parents_ids, parent[:parent_id])
    end
  end

  ##
  # Iterate through course files and create new BlacklightFile for each
  # non-metadata file.
  ##
  def self.iterate_files(zipfile)
    files = zipfile.entries.select(&:file?)

    file_names = files.map(&:name)
    scorm_paths = ScormPackage.find_scorm_paths(zipfile)

    files.select do |file|
      BlacklightFile.valid_file?(file_names, scorm_paths, file)
    end.
      map { |file| BlacklightFile.new(file) }
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
