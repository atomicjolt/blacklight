require "senkyoshi/models/questions/calculated"
require "senkyoshi/models/questions/either_or"
require "senkyoshi/models/questions/essay"
require "senkyoshi/models/questions/file_upload"
require "senkyoshi/models/questions/fill_in_blank"
require "senkyoshi/models/questions/fill_in_blank_plus"
require "senkyoshi/models/questions/hot_spot"
require "senkyoshi/models/questions/jumbled_sentence"
require "senkyoshi/models/questions/matching"
require "senkyoshi/models/questions/multiple_answer"
require "senkyoshi/models/questions/multiple_choice"
require "senkyoshi/models/questions/numerical"
require "senkyoshi/models/questions/opinion_scale"
require "senkyoshi/models/questions/ordering"
require "senkyoshi/models/questions/quiz_bowl"
require "senkyoshi/models/questions/short_response"
require "senkyoshi/models/questions/true_false"

require "senkyoshi/models/assessment"
require "senkyoshi/models/question_bank"
require "senkyoshi/models/survey"

require "senkyoshi/models/announcement"
require "senkyoshi/models/answer"
require "senkyoshi/models/qti"
require "senkyoshi/models/assignment"
require "senkyoshi/models/assignment_group"
require "senkyoshi/models/blog"
require "senkyoshi/models/content"
require "senkyoshi/models/content_file"
require "senkyoshi/models/course"
require "senkyoshi/models/file"
require "senkyoshi/models/forum"
require "senkyoshi/models/gradebook"
require "senkyoshi/models/group"
require "senkyoshi/models/module"
require "senkyoshi/models/module_item"
require "senkyoshi/models/question"
require "senkyoshi/models/quiz"
require "senkyoshi/models/resource"
require "senkyoshi/models/scorm_package"
require "senkyoshi/models/staff_info"
require "senkyoshi/models/wikipage"
require "senkyoshi/models/attachment"
require "senkyoshi/models/external_url"

require "senkyoshi/exceptions"

module Senkyoshi
  RESOURCE_TYPE = {
    groups: "Group",
    blog: "Blog",
    announcement: "Announcement",
    forum: "Forum",
    course: "Course",
    questestinterop: "QTI",
    content: "Content",
    staffinfo: "StaffInfo",
    gradebook: "Gradebook",
  }.freeze

  PRE_RESOURCE_TYPE = {
    content: "Content",
    gradebook: "Gradebook",
    courseassessment: "QTI",
  }.freeze

  def self.parse_manifest(zip_file, manifest, resource_xids)
    doc = Nokogiri::XML.parse(manifest)
    resources = doc.at("resources")
    organizations = doc.at("organizations")
    iterate_xml(organizations, resources, zip_file, resource_xids).
      flatten - ["", nil]
  end

  def self.iterate_xml(organizations, resources, zip_file, resource_xids)
    pre_data = pre_iterator(organizations, resources, zip_file)
    staff_info = StaffInfo.new
    iterator_master(resources, zip_file) do |xml_data, type, file|
      if RESOURCE_TYPE[type.to_sym]
        single_pre_data = get_single_pre_data(pre_data, file)
        res_class = Senkyoshi.const_get RESOURCE_TYPE[type.to_sym]
        case type
        when "content"
          Content.from(xml_data, single_pre_data, resource_xids)
        when "questestinterop"
          single_pre_data ||= { file_name: file }
          QTI.from(xml_data, single_pre_data)
        when "staffinfo"
          staff_info.iterate_xml(xml_data, single_pre_data)
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
        data_file = Senkyoshi.read_file(zip_file, file_name)
        xml_data = Nokogiri::XML.parse(data_file).children.first
        type = xml_data.name.downcase
        yield xml_data, type, file
      end
    end
  end

  def self.pre_iterator(organizations, resources, zip_file)
    pre_data = {}
    iterator_master(resources, zip_file) do |xml_data, type, file|
      if PRE_RESOURCE_TYPE[type.to_sym]
        res_class = Senkyoshi.const_get PRE_RESOURCE_TYPE[type.to_sym]
        pre_data[type] ||= []
        pre_data[type].push(res_class.get_pre_data(xml_data, file))
      end
    end
    pre_data = connect_content(pre_data)
    build_heirarchy(organizations, pre_data)
  end

  def self.connect_content(pre_data)
    pre_data["content"].each do |content|
      if pre_data["gradebook"]
        gradebook = pre_data["gradebook"].first.
          detect { |g| g[:content_id] == content[:file_name] }
        content.merge!(gradebook) if gradebook
      end
      if pre_data["courseassessment"]
        course_assessment = pre_data["courseassessment"].
          detect { |ca| ca[:original_file_name] == content[:assignment_id] }
        content.merge!(course_assessment) if course_assessment
      end
    end
    pre_data["content"]
  end

  def self.build_heirarchy(organizations, pre_data)
    unset_id = "{unset id}"
    parents = pre_data.
      select { |p| p[:parent_id] == unset_id }
    parents_ids = parents.map { |u| u[:id] }
    pre_data.each do |content|
      parent_id = content[:parent_id]
      parent = pre_data.detect { |p| p[:id] == parent_id }
      if parent_id == unset_id
        content[:title] = get_title(organizations, content)
      elsif parent[:parent_id] == unset_id
        content[:parent_title] = parent[:title]
      end
      next if parents_ids.include?(content[:id])
      next if parents_ids.include?(parent_id)
      parents_ids << parent_id
      parent[:parent_id] = parent[:id]
      parent[:parent_title] = nil
    end
  end

  def self.get_title(organizations, content)
    item = organizations.at("item[@identifierref=#{content[:file_name]}]")
    item.parent.at("title").text
  end

  ##
  # Iterate through course files and create new SenkyoshiFile for each
  # non-metadata file.
  ##
  def self.iterate_files(zipfile)
    files = zipfile.entries.select(&:file?)

    dir_names = zipfile.entries.map { |entry| File.dirname(entry.name) }.uniq
    file_names = files.map(&:name)
    entry_names = dir_names + file_names

    scorm_paths = ScormPackage.find_scorm_paths(zipfile)

    files.select do |file|
      SenkyoshiFile.valid_file?(entry_names, scorm_paths, file)
    end.
      map { |file| SenkyoshiFile.new(file) }
  end

  ##
  # Create a random hex prepended with aj_
  # This is because the instructure qti migration tool requires
  # the first character to be a letter.
  ##
  def self.create_random_hex
    "aj_" + SecureRandom.hex(32)
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
