$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'attach_it/version'

include_files = ["README*", "LICENSE", "Rakefile", "Gemfile", "{lib,test}/**/*"].map do |glob|
  Dir[glob]
end.flatten

exclude_files = ["test/test_helper", "test/unit", "test/unit/*", "test/tmp", "test/tmp/public", "test/tmp/public/*", "test/fixtures", "test/fixtures/*"].map do |glob|
  Dir[glob]
end.flatten

spec = Gem::Specification.new do |s|
  s.name              = "mm-attach-it"
  s.version           = AttachIt::Version
  s.author            = "Adilson Chacon"
  s.email             = "adilsonchacon@gmail.com"
  s.homepage          = "https://github.com/adilsonchacon/mm-attach-it"
  s.description       = "Attach files (images, videos, pdfs, txts, zips and etc) to a MongoMapper record. You can choose if you to store it on file system or GridFS."
  s.platform          = Gem::Platform::RUBY
  s.summary           = "MongoMapper Plugin File Attacher."
  s.files             = include_files - exclude_files
  s.require_path      = "lib"
  s.test_files        = Dir["test/**/test_*.rb"]
  s.rubyforge_project = "mm-attach_it"
  s.extra_rdoc_files  = Dir["README*"]
  s.requirements << "ImageMagick"
  s.add_dependency 'wand', '~> 0.4'
  s.add_dependency 'mongo_mapper', '~> 0.9.0'
  s.add_dependency 'rmagick'
  s.add_dependency 'mime-types'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'mocha'
end
