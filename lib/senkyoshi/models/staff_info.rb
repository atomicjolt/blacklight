require "senkyoshi/models/resource"

module Senkyoshi
  class StaffInfo < Resource
    attr_reader(
      :id,
      :title,
      :entries,
    )

    def initialize
      @entries = []
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
      @id ||= xml.xpath("//STAFFINFO/@id").text || Senkyoshi.create_random_hex
      @title ||= xml.xpath("//STAFFINFO/TITLE/@value").text
      bio = xml.xpath("//BIOGRAPHY/TEXT").text
      name = parse_name(contact)
      email = xml.xpath("//CONTACT/EMAIL/@value").text
      phone = xml.xpath("//CONTACT/PHONE/@value").text
      office_hours = xml.xpath("//OFFICE/HOURS/@value").text
      office_address = xml.xpath("//OFFICE/ADDRESS/@value").text
      home_page = xml.xpath("//HOMEPAGE/@value").text
      image = xml.xpath("//IMAGE/@value").text

      @entries << construct_body(
        bio: bio,
        name: name,
        email: email,
        phone: phone,
        office_hours: office_hours,
        office_address: office_address,
        home_page: home_page,
        image: image,
      )

      self
    end

    def append_str(body, str, var)
      body << str if var && !var.empty?
    end

    def construct_body(opts)
      body = "<div>"
      append_str body, "<img src=#{opts[:image]}/>", opts[:image]
      append_str body, "<h3>#{opts[:name]}</h3>", opts[:name]
      append_str body, "<p>#{opts[:bio]}</p>", opts[:bio]

      body << "<ul>"
      append_str body, "<li>Email: #{opts[:email]}</li>", opts[:email]
      append_str body, "<li>Phone: #{opts[:phone]}</li>", opts[:phone]
      append_str(
        body,
        "<li>Office Hours: #{opts[:office_hours]}</li>",
        opts[:office_hours],
      )
      append_str(
        body,
        "<li>Office Address: #{opts[:office_address]}</li>",
        opts[:office_address],
      )
      append_str(
        body,
        "<li>Home Page: #{opts[:home_page]}</li>",
        opts[:home_page],
      )
      body << "</ul></div>"
      body
    end

    def canvas_conversion(course, resources)
      page = CanvasCc::CanvasCC::Models::Page.new
      page.body = fix_html(@entries.join(" "), resources)
      page.identifier = @id
      page.page_name = @title.empty? ? "Contact" : @title

      course.pages << page
      course
    end
  end
end
