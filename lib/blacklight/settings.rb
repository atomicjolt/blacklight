require_relative 'exceptions'

module Blacklight

	GROUP_LOOKUP = {
		'title': 'name',
		'text': 'description',
		'isavailable': 'is_public'
	}

  def self.iterate_groups(xml_data, course)
  	# can't do with canvas_cc as far as I know might need to do it through the api
  	# just storing for now
  	values = {}
  	xml_data.children.each do |data, index|
  		if data.name == 'GROUP'
  			id = data.attributes["id"].value
  			values[id] = {}
  			data.children.each do |group|
  				name = group.name.downcase
  				case name
  				when 'title'
  					values[id][GROUP_LOOKUP[group.name.to_sym]] = group.attributes["value"].value
  				when 'description'
  					values[id][GROUP_LOOKUP[group.name.to_sym]] = group.children.at('TEXT').children.text
  				when 'flags'
  					values[id][GROUP_LOOKUP['isavailable'.to_sym]] = group.children.at('ISAVAILABLE').attributes["value"].value
  				end
  			end
  		end
  	end
  	course.add_to_values('groups', values)
  end

  def self.iterate_blog(xml_data, course)
  	# this is only supported with 3rd party integration at this point so just storing
  	values = {}
  	id = xml_data.attributes["id"].value
  	values[id] = {}
  	xml_data.children.each do |data|
  		name = data.name.downcase
  		case name
  		when 'title'
  			values[id][name] = data.attributes["value"].value
  		when 'description'
  			values[id][name] = data.children.at('TEXT').text
			when 'flags'
  			values[id]['is_public'] = data.children.at('ISAVAILABLE').attributes["value"].value
  		end
  	end
  	course.add_to_values('blogs', values)
  end

  def self.iterate_notificationrules(xml_data, course)
  end

  def self.iterate_staffinfo(xml_data, course)
  end

end