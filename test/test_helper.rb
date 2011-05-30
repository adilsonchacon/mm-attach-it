require 'rubygems'
require 'tempfile'
require 'mongo_mapper'
require 'shoulda'
require 'mocha'
require File.expand_path(File.dirname(__FILE__) + '/../lib/mm_attach_it')

MongoMapper.database = "testing_mm_attach_it"

FakeRailsRoot = File.join(File.dirname(__FILE__) + '/tmp/')

class Test::Unit::TestCase
  def setup
    public_dir = FakeRailsRoot + 'public/'
    FileUtils.rm_rf(public_dir) if File.exist?(public_dir) 
    FileUtils.mkdir_p(public_dir)
    MongoMapper.database.collections.each(&:remove)
  end
end

class UserOne
  include MongoMapper::Document
  plugin AttachIt
  key :name, String
  has_attachment :avatar
end

class UserTwo
  include MongoMapper::Document
  plugin AttachIt
  key :name, String 
  has_attachment :avatar, { :url => '/assets/users/:id/:filename', :path => ':rails_root/public/assets/users/:id/:filename' }
end

class UserThree
  include MongoMapper::Document
  plugin AttachIt
  key :name, String 
  has_attachment :avatar, { :styles => { :small => '150x150>', :medium => '300x300>' } }
end

class UserFour
  include MongoMapper::Document
  plugin AttachIt
  key :name, String 
  has_attachment :avatar, { :default_url => '/images/default/avatar.jpg' }
end

class UserFive
  include MongoMapper::Document
  plugin AttachIt
  key :name, String 
  has_attachment :avatar

  validates_attachment_size :avatar, :less_than => 1.megabyte
end

class UserSix
  include MongoMapper::Document
  plugin AttachIt
  key :name, String 
  has_attachment :avatar

  validates_attachment_size :avatar, :less_than => 90.kilobytes
end

class UserSeven
  include MongoMapper::Document
  plugin AttachIt
  key :name, String 
  has_attachment :avatar

  validates_attachment_size :avatar, :greater_than => 90.kilobytes
end

class UserEight
  include MongoMapper::Document
  plugin AttachIt
  key :name, String 
  has_attachment :avatar

  validates_attachment_size :avatar, :greater_than => 1.megabyte
end

class UserNine
  include MongoMapper::Document
  plugin AttachIt
  key :name, String 
  has_attachment :avatar

  validates_attachment_presence :avatar
end

class UserTen
  include MongoMapper::Document
  plugin AttachIt
  key :name, String 
  has_attachment :avatar

  validates_attachment_content_type :avatar, :content_type => ['image/gif', 'image/png']
end

class UserEleven
  include MongoMapper::Document
  plugin AttachIt
  key :name, String 
  has_attachment :avatar

  validates_attachment_content_type :avatar, :content_type => ['image/jpg', 'image/jpeg']
end

class UserTwelve
  include MongoMapper::Document
  plugin AttachIt
  key :name, String 
  has_attachment :avatar, { :styles => { :small => '150x150>', :medium => '300x300>' }, :storage => 'gridfs' }
end

class DocumentOne
  include MongoMapper::Document
  plugin AttachIt
  key :name, String
  has_attachment :document
end

class Rails
  def self.env
    'test'
  end

  def self.root
    File.join(File.dirname(__FILE__) + '/tmp/')
  end
end
