
require_relative 'exceptions'

module Blacklight

	FUNCTION_CALL = {
	  "course": :iterate_course,
	  "standard_sub_document_association": :iterate_ssda,
	  "navigationapplications":  :iterate_navigateapplications
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
			data_details = data.children.first
			type = data_details.name.downcase
			Blacklight.send(FUNCTION_CALL[type.to_sym], data_details, course) if FUNCTION_CALL[type.to_sym]
		end
	end

	def self.iterate_course(data_details, course)
		data_details.children.each do |data|
			name = data.name.downcase
			if name == 'courseid'
				value = data.attributes["value"].value
				course.set_course_values('identification', value)
			elsif name == 'title'
				value = data.attributes["value"].value
				course.set_course_values(name, value)
			end
		end
	end

	def self.iterate_ssda(data_details, course)
	end

	def self.iterate_navigateapplications(data_details, course)
	end

end