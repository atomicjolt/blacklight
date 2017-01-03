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
      @@entries |= []
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

    def construct_body
      <<-HTML
        <div>
          <h3>#{@name}</h3>
          <p>#{@bio}</p>
          <ul>
            <li>Email: #{@email}</li>
            <li>Phone: #{@phone}</li>
            <li>Office Hours: #{@office_hours}</li>
            <li>Office Address: #{@office_address}</li>
          </ul>
        </div>
      HTML
    end

    def canvas_conversion(course, _resources = nil)
      # We want to create only a single "Contact" page, so once we already have
      # a StaffInfo resource, we won't want another one
      return course if @@page_created

      page = CanvasCc::CanvasCC::Models::Page.new
      page.body = @@entries.join(" ")
      page.identifier = @id
      page.page_name = @title.empty? ? "Contact" : @title
      @@page_created = true

      course.pages << page
      course
    end
  end
end
