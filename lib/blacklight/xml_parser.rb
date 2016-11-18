require_relative "exceptions"

module Blacklight

	FUNCTION_TYPE_CALL = {
	  course: :iterate_course,
	  groups: :iterate_groups,
	  blog: :iterate_blog,
	  announcement: :iterate_announcement,
	  forum: :iterate_forum,

	  categories: :iterate_categories,
	  itemcategories: :iterate_itemcategories,
	  questestinterop: :iterate_questestinterop,
	  staffinfo: :iterate_staffinfo,
	  coursemodulepages: :iterate_coursemodulepages,
	  content: :iterate_content,
	  groupcontentlist: :iterate_groupcontentlist,
	  learnrubrics: :iterate_learnrubrics,
	  gradebook: :iterate_gradebook,
	  courseassessment: :iterate_courseassessment,
	  collabsessions: :iterate_collabsessions,
	  link: :iterate_link,
	  cms_resource_link_list: :iterate_resource_link_list,
	  courserubricassociations: :iterate_courserubricassociations,
	  partentcontextinfo: :iterate_parentcontextinfo,
	  notificationrules: :iterate_notificationrules,
	  wiki: :iterate_wiki,
	  safeassign: :iterate_safeassign
	};

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
			Blacklight.send(FUNCTION_TYPE_CALL[type.to_sym], xml_data, course) if FUNCTION_TYPE_CALL[type.to_sym]
		end
	end

	def self.create_random_hex
    "i" + SecureRandom.hex
  end

  def self.get_attribute_value(xml_data, type)
    xml_data.children.at(type).attributes["value"].value
  end

  def self.get_text(xml_data)
    xml_data.children.at("DESCRIPTION").children.at("TEXT").text
  end

  def self.get_description(xml_data)
    xml_data.children.at("DESCRIPTION").text
  end

  def self.iterate_categories(xml_data, course)
  end

  def self.iterate_itemcategories(xml_data, course)
  end

  def self.iterate_questestinterop(xml_data, course)
  end

  def self.iterate_assessmentcreationsettings(xml_data, course)
  end

  def self.iterate_learnrubrics(xml_data, course)
  end

  def self.iterate_gradebook(xml_data, course)
  end

  def self.iterate_courseassessment(xml_data, course)
  end

  def self.iterate_collabsessions(xml_data, course)
  end

  def self.iterate_link(xml_data, course)
  end

  def self.iterate_resource_link_list(xml_data, course)
  end

  def self.iterate_courserubricassociations(xml_data, course)
  end

  def self.iterate_parentcontextinfo(xml_data, course)
  end

  def self.iterate_safeassign(xml_data, course)
  end

	def self.iterate_wiki(xml_data, course)
  end

  def self.iterate_conferences(xml_data, course)
  end

  def self.iterate_coursemodulepages(xml_data, course)
  end

  def self.iterate_notificationrules(xml_data, course)
  end

  def self.iterate_staffinfo(xml_data, course)
  end

  def self.iterate_groupcontentlist(xml_data, course)
  end

  def self.iterate_content(xml_data, course)
  end


end
