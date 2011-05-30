require File.join(File.dirname(__FILE__), '../test_helper')

JpgImageFile = File.join(File.dirname(__FILE__) + '/../fixtures/lake_moraine.jpg')
PdfFile = File.join(File.dirname(__FILE__) + '/../fixtures/example.pdf')
FakeImageFile = File.join(File.dirname(__FILE__) + '/../fixtures/fakeimage.jpg')

class TestAttachIt < Test::Unit::TestCase
  context "#initialize" do
    setup do
      @user = UserOne.new
      @user.name = 'Myname'
    end

    should "set instance of image_options" do
      assert_instance_of AttachmentOptions, @user.avatar
    end
  end

  context "Attaching an image on file system" do
    setup do
      @user = UserOne.new
      @user.name = 'Myname'
      @user.avatar = File.open(JpgImageFile, 'rb')
    end

    should "respond with path and url methods with default value" do
      destiny_file = Rails.root + 'public/system/avatars/' + @user.id.to_s + '/original/lake_moraine.jpg'
      assert_equal(destiny_file, @user.avatar.path)

      destiny_url = '/system/avatars/' + @user.id.to_s + '/original/lake_moraine.jpg'
      assert_equal(destiny_url, @user.avatar.url)
    end

    should "create file and informations columns after save" do
      destiny_file = Rails.root + 'public/system/avatars/' + @user.id.to_s + '/original/lake_moraine.jpg'
      @user.save
      assert(File.exist?(destiny_file))
      assert_equal('lake_moraine.jpg', @user.avatar_file_name)
      assert_equal('image/jpeg', @user.avatar_content_type)
      assert_equal(102520, @user.avatar_file_size)
      assert_instance_of(Date, @user.avatar_updated_at)
    end

    should "retreive correct informations" do
      destiny_file = Rails.root + 'public/system/avatars/' + @user.id.to_s + '/original/lake_moraine.jpg'
      destiny_url = '/system/avatars/' + @user.id.to_s + '/original/lake_moraine.jpg'

      @user.save

      saved_user = UserOne.find(@user.id.to_s)
      assert_equal(destiny_file, saved_user.avatar.path)
      assert_equal(destiny_url, saved_user.avatar.url)
      assert_equal('lake_moraine.jpg', saved_user.avatar_file_name)
      assert_equal(102520, saved_user.avatar_file_size)
      assert_equal('image/jpeg', saved_user.avatar_content_type)
      assert_instance_of(Date, saved_user.avatar_updated_at)
      assert_equal(@user.avatar_updated_at, saved_user.avatar_updated_at)
    end

  end


  context "Attaching not an image on file system" do
    
  end
    setup do
      @doc = DocumentOne.new
      @doc.name = 'Mydocument'
      @doc.document = File.open(PdfFile, 'rb')
    end

    should "respond with path and url methods with default value" do
      destiny_file = Rails.root + 'public/system/documents/' + @doc.id.to_s + '/original/example.pdf'
      assert_equal(destiny_file, @doc.document.path)

      destiny_url = '/system/documents/' + @doc.id.to_s + '/original/example.pdf'
      assert_equal(destiny_url, @doc.document.url)
    end

    should "create file and informations columns after save" do
      destiny_file = Rails.root + 'public/system/documents/' + @doc.id.to_s + '/original/example.pdf'
      @doc.save
      assert(File.exist?(destiny_file))
      assert_equal('example.pdf', @doc.document_file_name)
      assert_equal('application/pdf', @doc.document_content_type)
      assert_equal(9785, @doc.document_file_size)
      assert_instance_of(Date, @doc.document_updated_at)
    end

    should "retreive correct informations from db" do
      destiny_file = Rails.root + 'public/system/documents/' + @doc.id.to_s + '/original/example.pdf'
      destiny_url = '/system/documents/' + @doc.id.to_s + '/original/example.pdf'

      @doc.save

      saved_doc = DocumentOne.find(@doc.id.to_s)
      assert_equal(destiny_file, saved_doc.document.path)
      assert_equal(destiny_url, saved_doc.document.url)
      assert_equal('example.pdf', saved_doc.document_file_name)
      assert_equal('application/pdf', saved_doc.document_content_type)
      assert_equal(9785, saved_doc.document_file_size)
      assert_instance_of(Date, saved_doc.document_updated_at)
      assert_equal(@doc.document_updated_at, saved_doc.document_updated_at)
    end
  end
  
  context "Creating differents sizes from an image" do
    setup do
      @user = UserThree.new
      @user.name = 'Myname'
      @user.avatar = File.open(JpgImageFile, 'rb')
    end

    should "respond with path and url methods by styles" do
      [:small, :medium, :original].each do |style|
        destiny_file = Rails.root + 'public/system/avatars/' + @user.id.to_s + '/' + style.to_s + '/lake_moraine.jpg'
        assert_equal(destiny_file, @user.avatar.path(style))

        destiny_url = '/system/avatars/' + @user.id.to_s + '/' + style.to_s + '/lake_moraine.jpg'
        assert_equal(destiny_url, @user.avatar.url(style))
      end
    end

    should "create file after save by styles" do
      @user.save
      [:small, :medium, :original].each do |style|
        destiny_file = Rails.root + 'public/system/avatars/' + @user.id.to_s + '/' + style.to_s + '/lake_moraine.jpg'
        assert(File.exist?(destiny_file))
      end
    end

    should "return the base64 from file" do
      @user.save
      assert_match(/^data:image\/jpeg;base64,/, @user.avatar.base64)
      assert_match(/^data:image\/jpeg;base64,/, @user.avatar.base64('small'))
      assert_match(/^data:image\/jpeg;base64,/, @user.avatar.base64('medium'))
      assert_match(/^data:image\/jpeg;base64,/, @user.avatar.base64('original'))
    end
  end

  context "Set the url and path" do
    setup do
      @user = UserTwo.new
      @user.name = 'Myname'
      @user.avatar = File.open(JpgImageFile, 'rb')
    end

    should "respond with path and url" do
      destiny_file = Rails.root + 'public/assets/users/' + @user.id.to_s + '/lake_moraine.jpg'
      assert_equal(destiny_file, @user.avatar.path)

      destiny_url = '/assets/users/' + @user.id.to_s + '/lake_moraine.jpg'
      assert_equal(destiny_url, @user.avatar.url)
    end

    should "retreive correct informations from db" do
      destiny_file = Rails.root + 'public/assets/users/' + @user.id.to_s + '/lake_moraine.jpg'
      destiny_url = '/assets/users/' + @user.id.to_s + '/lake_moraine.jpg'

      @user.save

      saved_user = UserTwo.find(@user.id.to_s)
      assert_equal(destiny_file, saved_user.avatar.path)
      assert_equal(destiny_url, saved_user.avatar.url)
    end
  end

  context "Use default URL" do
    setup do
      @user = UserFour.new
      @user.name = 'Myname'
    end

    should "retreive correct informations from db" do
      destiny_url = '/images/default/avatar.jpg'

      @user.save

      saved_user = UserFour.find(@user.id.to_s)
      assert_equal(destiny_url, saved_user.avatar.url)
    end
  end

  context "Handle errors" do
    setup do
    end

    should "have an error if file can't be resized" do
      user = UserThree.new
      user.name = 'Myname'
      user.avatar = File.open(FakeImageFile)
      user.save

      assert_equal(user.errors.size, 1)
      assert_equal(user.errors[:avatar].first, 'Could not resize file')
    end

    should "haven't an error if file size is less than a specific value" do
      user = UserFive.new
      user.name = 'Myname'
      user.avatar = File.open(JpgImageFile, 'rb')
      user.save

      assert_equal(user.errors.size, 0)
    end

    should "have an error if file size is not less than a specific value" do
      user = UserSix.new
      user.name = 'Myname'
      user.avatar = File.open(JpgImageFile, 'rb')
      user.save

      assert_equal(user.errors.size, 1)
      assert_equal(user.errors[:avatar_file_size].first, 'file size must be between 0 and 92160 bytes')
    end

    should "haven't error if file size is greater than a specific value" do
      user = UserSeven.new
      user.name = 'Myname'
      user.avatar = File.open(JpgImageFile, 'rb')
      user.save

      assert_equal(user.errors.size, 0)
    end

    should "have an error if file size is not greater than a specific value" do
      user = UserEight.new
      user.name = 'Myname'
      user.avatar = File.open(JpgImageFile, 'rb')
      user.save

      assert_equal(user.errors.size, 1)
      assert_equal(user.errors[:avatar_file_size].first, 'file size must be between 1048576 and Infinity bytes')
    end

    should "have an error if file size is not greater than a specific value" do
      user = UserNine.new
      user.name = 'Myname'
      user.save

      assert_equal(user.errors.size, 1)
      assert_equal(user.errors[:avatar_file_name].first, 'must be set')
    end

    should "have an error if file content type is not one of the specifieds" do
      user = UserTen.new
      user.name = 'Myname'
      user.avatar = File.open(JpgImageFile, 'rb')
      user.save

      assert_equal(user.errors.size, 1)
      assert_equal(user.errors[:avatar_content_type].first, 'is not one of image/gif, image/png')
    end

    should "haven't error if file content type is one of the specifieds" do
      user = UserEleven.new
      user.name = 'Myname'
      user.avatar = File.open(JpgImageFile, 'rb')
      user.save

      assert_equal(user.errors.size, 0)
    end
  end

  context "Gridfs behavior" do
    setup do
      @user = UserTwelve.new
      @user.name = 'Myname'
      @user.avatar = File.open(JpgImageFile, 'rb')
      @user.save
    end

    should "save the images resizeds and the original" do
      assert_equal(@user.avatar.get_from_gridfs.class, Mongo::GridIO)
      assert_equal(@user.avatar.get_from_gridfs('small').class, Mongo::GridIO)
      assert_equal(@user.avatar.get_from_gridfs('medium').class, Mongo::GridIO)
      assert_equal(@user.avatar.get_from_gridfs('original').class, Mongo::GridIO)
    end

    should "return the base64 from file" do
      assert_match(/^data:image\/jpeg;base64,/, @user.avatar.base64)
      assert_match(/^data:image\/jpeg;base64,/, @user.avatar.base64('small'))
      assert_match(/^data:image\/jpeg;base64,/, @user.avatar.base64('medium'))
      assert_match(/^data:image\/jpeg;base64,/, @user.avatar.base64('original'))
    end

  end

end
