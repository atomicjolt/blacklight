require "senkyoshi/models/resource"

module Senkyoshi
  class StaffInfo < Resource
    attr_reader(
      :id,
      :title,
      :bio,
      :name,
      :email,
      :phone,
      :office_hours,
      :office_address,
      :home_page,
      :image,
    )

    def self.reset_entries
      @@entries = []
      @@page_created = false
    end

    def initialize
      @@entries ||= []
      @@page_created = false
    end

    def parse_name(contact)
      parts = [
        contact.xpath("./NAME/FORMALTITLE/@value").text,
        contact.xpath("./NAME/GIVEN/@value").text,
        contact.xpath("./NAME/FAMILY/@value").text,
      ]

      resp = ""
      parts.each do |part|
        resp << " " unless resp.empty?
        resp << part unless part.empty?
      end
      resp
    end

    def iterate_xml(xml, _pre_data)
      contact = xml.xpath("//CONTACT")
      @id = xml.xpath("//STAFFINFO/@id").text
      @title = xml.xpath("//STAFFINFO/TITLE/@value").text
      @bio = xml.xpath("//BIOGRAPHY/TEXT").text
      @name = parse_name(contact)
      @email = xml.xpath("//CONTACT/EMAIL/@value").text
      @phone = xml.xpath("//CONTACT/PHONE/@value").text
      @office_hours = xml.xpath("//OFFICE/HOURS/@value").text
      @office_address = xml.xpath("//OFFICE/ADDRESS/@value").text
      @home_page = xml.xpath("//HOMEPAGE/@value").text
      @image = xml.xpath("//IMAGE/@value").text

      @@entries << construct_body

      self
    end

    def add_to_body(str, var)
      @body << str if var && !var.empty?
    end

    def construct_body
      @body = "<div>"
      add_to_body "<img src=#{@image}/>", @image
      add_to_body "<h3>#{@name}</h3>", @name
      add_to_body "<p>#{@bio}</p>", @bio

      @body << "<ul>"
      add_to_body "<li>Email: #{@email}</li>", @email
      add_to_body "<li>Phone: #{@phone}</li>", @phone
      add_to_body "<li>Office Hours: #{@office_hours}</li>", @office_hours
      add_to_body "<li>Office Address: #{@office_address}</li>", @office_address
      add_to_body "<li>Home Page: #{@home_page}</li>", @home_page
      @body << "</ul></div>"
    end

    def canvas_conversion(course, resources)
      # We want to create only a single "Contact" page, so once we already have
      # a StaffInfo resource, we won't want another one
      return course if @@page_created

      page = CanvasCc::CanvasCC::Models::Page.new
      page.body = fix_html(@@entries.join(" "), resources)
      page.identifier = @id
      page.page_name = @title.empty? ? "Contact" : @title
      @@page_created = true

      course.pages << page
      course
    end
  end
end
