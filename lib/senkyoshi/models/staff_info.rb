require "senkyoshi/models/root_resource"
require "active_support/core_ext/string"

module Senkyoshi
  class StaffInfo < RootResource
    attr_reader(
      :title,
      :entries,
    )

    def initialize(resource_id = nil)
      super(resource_id)
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

    def humanize(symbol)
      symbol.to_s.humanize.titleize
    end

    def construct_body(opts)
      body = "<div>"
      append_str body, "<img src=#{opts[:image]}/>", opts[:image]
      append_str body, "<h3>#{opts[:name]}</h3>", opts[:name]
      append_str body, "<p>#{opts[:bio]}</p>", opts[:bio]

      body << "<ul>"
      [:email, :phone, :office_hours, :office_address, :home_page].each do |key|
        append_str body, "<li>#{humanize(key)}: #{opts[key]}</li>", opts[key]
      end
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
