require_relative 'exceptions'

module Blacklight

	FUNCTION_TYPE_CALL = {
	  "course": :iterate_course,
	  "navigationapplications":  :iterate_navigateapplications,
	  "navigationsettings": :iterate_navigationsettings,
	  "coursetoc": :iterate_coursetoc,
	  "contenthandlers": :iterate_contenthandlers,
	  "categories": :iterate_categories,
	  "itemcategories": :iterate_itemcategories,
	  "groups": :iterate_groups,
	  "groupapplications": :iterate_groupapplications,
	  "blog": :iterate_blog,
	  "questestinterop": :iterate_questestinterop,
	  "assessmentcreationsettings": :iterate_assessmentcreationsettings,
	  "announcement": :iterate_announcement,
	  "conferences": :iterate_conferences,
	  "forum": :iterate_forum,
	  "staffinfo": :iterate_staffinfo,
	  "coursemodulepages": :iterate_coursemodulepages,
	  "content": :iterate_content,
	  "groupcontentlist": :iterate_groupcontentlist,
	  "learnrubrics": :iterate_learnrubrics,
	  "gradebook": :iterate_gradebook,
	  "courseassessment": :iterate_courseassessment,
	  "collabsessions": :iterate_collabsessions,
	  "link": :iterate_link,
	  "cms_resource_link_list": :iterate_resource_link_list,
	  "courserubricassociations": :iterate_courserubricassociations,
	  "partentcontextinfo": :iterate_parentcontextinfo,
	  "notificationrules": :iterate_notificationrules,
	  "wiki": :iterate_wiki,
	  "safeassign": :iterate_safeassign
	};

	COURSE_LOOKUP = {
		"isavailable": "is_public",
		"title": "title",
		"description": "description"
	}

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

	def self.iterate_course(xml_data, course)
		course.set_course_values('identifier', xml_data["id"])
		xml_data.children.each do |data|
			name = data.name.downcase
			case name
			when 'title','isavailable'
				if data.attributes
					value = data.attributes["value"].value
					course.set_course_values(COURSE_LOOKUP[name.to_sym], value)
				end
			when 'dates'
				data.children.each do |date|
					if data.name.downcase == 'coursestart'
						value = data.attributes['value'].value
						course.set_course_values('start_at', value)
					elsif data.name.downcase == 'courseend'
						value = data.attributes['value'].value
						course.set_course_values('conclude_at', value)
					end
				end
			when 'description'
				value = data.text
				course.set_course_values(COURSE_LOOKUP[name.to_sym], value)
			else
				puts name + 'is not found or is not used'
			end
		end
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


end