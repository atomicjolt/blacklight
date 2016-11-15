
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
			parse_data_file(data_file, course)
		end
	end

	def self.parse_data_file(data_file, course)
		data = Nokogiri::XML.parse(data_file)
		data_details = data.children.first
		type = data_details.name.downcase
		call_function(type, data_details)
	end

	def self.call_function(type, data_details)
		Blacklight.send(FUNCTION_CALL[type.to_sym], data_details) if FUNCTION_CALL[type.to_sym]
	end

	def self.iterate_course(data_details)
		data_details.children.each do |data|
			type = data.name.downcase
			if type == 'courseid'
				value = data.attributes["value"].value
			end
		end
	end

	def self.iterate_ssda(data)
	end

	def self.iterate_navigateapplications(data)

	end

end