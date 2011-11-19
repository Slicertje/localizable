Gem::Specification.new do |spec|
    spec.name = 'localizable'
    spec.author = 'Stefaan Colman'
    spec.description = 'An easy way to localize fields of MongoMapper::Document classes'
    spec.summary = 'Localize your models'

    spec.files = Dir.glob("lib/**/*.rb") + Dir.glob("tests/**/*") + %w(README)
    spec.test_files = Dir.glob("tests/**/*.rb")

    spec.version = '1.1'
end
