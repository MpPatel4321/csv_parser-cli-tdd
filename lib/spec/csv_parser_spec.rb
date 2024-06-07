# frozen_string_literal: true

require_relative "../csv_parser/csv_parser" # Assuming your script is named cli.rb
RSpec.describe "CsvParser" do
  let(:csv_parser) { CsvParser::CsvParser.new }
  describe "#write_output_csv" do
    let(:valid_csv) { "lib/fixtures/valid_client_list.csv" }
    let(:invalid_csv) { "lib/fixtures/invalid_client_list.csv" }
    let(:output_csv) { "outputs/output_123.csv" }
    let(:output_data) { CSV.read(output_csv, headers: true) }

    before do
      test_time = OpenStruct.new(tv_sec: 123)
      allow(Time).to receive(:now).and_return(test_time)
    end

    after do
      File.delete(output_csv) if File.exist?(output_csv)
    end

    it "writes valid rows to the output CSV" do
      csv_parser.write_output_csv(valid_csv)
      expect(output_data.headers).to include("Email")
      expect(output_data.size).to eq(1)
    end

    it "skips invalid rows and writes headers only once" do
      csv_parser.write_output_csv(invalid_csv)
      expect(output_data.headers).to include("Email")
      expect(output_data.size).to eq(0)
    end
  end

  describe "#run" do
    context "when --help option is provided" do
      it "prints help message and exits" do
        ARGV.replace(["--help"])

        expect { csv_parser.run }.to output(/Usage:/).to_stdout.and raise_error(SystemExit)
      end
    end

    context "when input CSV is not provided" do
      it "prints an error message and exits with status 1" do
        ARGV.clear

        expect { csv_parser.run }.to output(/Error: Please provide an input file/).to_stdout.and raise_error(SystemExit)
      end
    end

    context "when a valid input CSV is provided" do
      let(:valid_csv) { "lib/fixtures/valid_client_list.csv" }

      it "calls write_output_csv with the correct input" do
        ARGV.replace([valid_csv])

        expect { csv_parser.run }.not_to raise_error
      end
    end
  end

  describe "#is_nil_data?" do
    it "returns true when all values are present" do
      data = { "Name" => "John", "Email" => "john@example.com" }
      expect(csv_parser.is_nil_data?(data)).to be_falsy
    end

    it "returns false when some values are missing" do
      data = { "Name" => "John", "Email" => nil }
      expect(csv_parser.is_nil_data?(data)).to be_truthy
    end
  end

  describe "#valid_email?" do
    it "returns true for a valid email" do
      email = "test@example.com"
      expect(csv_parser.valid_email?(email)).to be true
    end

    it "returns false for an invalid email" do
      email = "test@example"
      expect(csv_parser.valid_email?(email)).to be false
    end
  end

  describe "#geocode_location" do
    it "returns true for a valid address" do
      data = {
        "Postal Address Street" => "1600 Amphitheatre Parkway",
        "Postal Address Locality" => "Mountain View",
        "Postal Address State" => "CA",
        "Postal Address Postcode" => "94043"
      }
      expect(csv_parser.geocode_location(data, "Postal")).to be_falsy
    end

    it "returns false for an invalid address" do
      data = {
        "Residential Address Street" => "Invalid Address",
        "Residential Address Locality" => "City",
        "Residential Address State" => "CA",
        "Residential Address Postcode" => "12345"
      }
      expect(csv_parser.geocode_location(data, "Residential")).to be_truthy
    end
  end
  describe "#print_help" do
    it "prints the help message to STDOUT" do
      allow(csv_parser).to receive(:puts)

      csv_parser.print_help

      expected_help_message = <<-HELP
        Usage: ./cli [OPTIONS/FILE]

        Options:
          --help                 Print this help message
        File:
          file_dir(input.csv)    Specify output file (default: STDOUT)

        Examples:
          ./cli --help
          ./cli input.csv        # will generate output.csv in your current directry.
      HELP

      expect(csv_parser).to have_received(:puts).with(expected_help_message)
    end
  end
end
