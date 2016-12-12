require "pandarus"
require "blacklight/config"
require "rest-client"

module Blacklight
  class CanvasCourse
    def initialize(metadata, course_resource)
      @metadata = metadata
      @course_resource = course_resource
    end

    def self.metadata_from_file(filename)
      Zip::File.open(filename) do |file|
        settings = "course_settings/course_settings.xml"
        config = file.find_entry(settings).get_input_stream.read
        doc = Nokogiri::XML(config)
        {
          name: doc.at("title").text,
        }
      end
    end

    def self.client
      @client ||= Pandarus::Client.new(
        prefix: Blacklight.canvas_url,
        token: Blacklight.canvas_token,
      )
    end

    def self.from_metadata(metadata)
      course_name = metadata[:name] || metadata[:title]
      courses = client.list_active_courses_in_account(:self)
      course = courses.detect { |c| c.name == course_name } ||
        client.create_new_course(
          :self,
          course: {
            name: metadata[:name],
          },
        )
      CanvasCourse.new(metadata, course)
    end

    def upload_content(filename)
      client = CanvasCourse.client
      name = File.basename(filename)
      migration = client.
        create_content_migration_courses(
          @course_resource.id,
          :canvas_cartridge_importer,
          pre_attachment: { name: name },
        )

      pre_attachment = migration.pre_attachment
      upload_url = pre_attachment["upload_url"]
      upload_params = pre_attachment["upload_params"]
      upload_params[:file] = File.new(filename, "rb")

      puts "Uploading: #{name}"
      RestClient.post(
        upload_url,
        upload_params,
      ) do |response|
        code = response.code
        if code == 302 || code == 303
          RestClient.post(
            response.headers[:location],
            nil,
            Authorization: "Bearer #{Blacklight.canvas_token}",
          )
        end
      end
      puts "Done uploading: #{name}"
    end
  end
end
