require "pandarus"
require "blacklight/config"
require "rest-client"

module Blacklight
  ##
  # This class represents a canvas course for which we are uploading data to
  ##
  class CanvasCourse
    ##
    # A new canvas course accepts the metadata for a course
    # and the pandarus course resourse
    ##
    def initialize(metadata, course_resource)
      @metadata = metadata
      @course_resource = course_resource
    end

    ##
    # Given a filename to a zip file, extract the necessary metadata
    # for the course
    ##
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

    ##
    # Create a new pandarus instance to communicate with the canvas server
    ##
    def self.client
      @client ||= Pandarus::Client.new(
        prefix: Blacklight.canvas_url,
        token: Blacklight.canvas_token,
      )
    end

    ##
    # Find or Create a new CanvasCourse instance from the given metadata
    ##
    def self.from_metadata(metadata)
      course_name = metadata[:name] || metadata[:title]
      courses = client.list_active_courses_in_account(Blacklight.account_id)
      canvas_course = courses.detect { |course| course.name == course_name } ||
        client.create_new_course(
          Blacklight.account_id,
          course: {
            name: course_name,
          },
        )
      CanvasCourse.new(metadata, canvas_course)
    end

    ##
    # Create a migration for the course
    # and upload the imscc file to be imported into the course
    ##
    def upload_content(filename)
      client = CanvasCourse.client
      name = File.basename(filename)
      # Create a migration for the course and get S3 upload authorization
      migration = client.
        create_content_migration_courses(
          @course_resource.id,
          :canvas_cartridge_importer,
          pre_attachment: { name: name },
        )

      puts "Uploading: #{name}"
      upload_to_s3(migration, filename)
      puts "Done uploading: #{name}"
    end

    def upload_to_s3(migration, filename)
      # Attach the file to the S3 auth
      pre_attachment = migration.pre_attachment
      upload_url = pre_attachment["upload_url"]
      upload_params = pre_attachment["upload_params"]
      upload_params[:file] = File.new(filename, "rb")

      # Post to S3
      RestClient.post(
        upload_url,
        upload_params,
      ) do |response|
        # Post to Canvas
        RestClient.post(
          response.headers[:location],
          nil,
          Authorization: "Bearer #{Blacklight.canvas_token}",
        )
      end
    end
  end
end
