# frozen_string_literal: true

require "csv"
require "optparse"
require "geocoder"

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

module CsvParser
  class CsvParser

    EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z]+)*\.[a-z]+\z/i.freeze

    def run
      options = {}
      OptionParser.new do |opts|
        opts.on("--help", "Print this help message") do
          print_help
          exit
        end
      end.parse!

      input_csv = ARGV.first

      if input_csv.nil?
        puts "Error: Please provide an input file."
        exit 1
      end

      write_output_csv(input_csv)
    end

    def write_output_csv(input_csv)
      output_file = "outputs/output_#{Time.now.tv_sec}.csv"
      CSV.open(output_file, "w", headers: true, write_headers: true) do |csv|
        CSV.foreach(input_csv, headers: true) do |row|
          csv << row.headers if csv.headers.nil?
          next if valid_data?(csv, row.to_hash)

          csv << row
        end
      end
      puts "You can see your result in `#{output_file}`"
    end

    def valid_data?(_csv, data)
      is_nil_data?(data) || !valid_email?(data["Email"]) ? true : validate_address?(data)
    end

    def is_nil_data?(data)
      data.values.include?(nil)
    end

    def valid_email?(email)
      !!(email =~ EMAIL_REGEX)
    end

    def validate_address?(data)
      geocode_location(data, "Residential") || geocode_location(data, "Postal")
    end

    def geocode_location(data, type)
      Geocoder.search(address(data, type)).empty?
    end

    def address(data, type)
      [
        data["#{type} Address Street"],
        data["#{type} Address Locality"],
        data["#{type} Address State"],
        data["#{type} Address Postcode"]
      ].join(",")
    end

    def print_help
      puts <<-HELP
        Usage: ./cli [OPTIONS/FILE]

        Options:
          --help                 Print this help message
        File:
          file_dir(input.csv)    Specify output file (default: STDOUT)

        Examples:
          ./cli --help
          ./cli input.csv        # will generate output.csv in your current directry.
      HELP
    end
  end
end
