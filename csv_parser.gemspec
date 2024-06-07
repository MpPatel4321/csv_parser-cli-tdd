# frozen_string_literal: true

require_relative "lib/csv_parser/version"

Gem::Specification.new do |spec|
  spec.name          = "csv_parser"
  spec.version       = CsvParser::VERSION
  spec.authors       = ["Salvi Mohan"]
  spec.email         = ["salvi.mohan4@gmail.com"]
  spec.summary       = 'This gem is parse user detailed CSV'
  spec.description   = 'It parsed the CSV with proper address Validation and generate a new output CSV with the valid data'
  
  spec.required_ruby_version = ">= 2.6.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end

  spec.bindir          = "exe"
  spec.require_paths   = ["lib"]
  spec.files           = Dir['lib/**/*.rb']

  spec.add_dependency 'geocoder'
end
