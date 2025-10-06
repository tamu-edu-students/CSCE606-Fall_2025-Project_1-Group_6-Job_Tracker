# spec/models/user_spec.rb
require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:phone) }
    it { is_expected.to validate_presence_of(:email) }

    it "validates email format" do
      user = build(:user, email: "bad-email")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("must be a valid email address")
    end

    it "validates phone format" do
      user = build(:user, phone: "123")
      expect(user).not_to be_valid
      expect(user.errors[:phone]).to include(a_string_matching(/must be a valid phone number/))
    end

    it "requires password length and complexity" do
      user = build(:user, password: "short", password_confirmation: "short")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include(a_string_matching(/at least 8/))

      user2 = build(:user, password: "alllowercase", password_confirmation: "alllowercase")
      expect(user2).not_to be_valid
      expect(user2.errors[:password]).to include(a_string_matching(/one uppercase letter/))
    end

    it "requires password_confirmation match when password set" do
      user = build(:user, password: "Passw0rd!", password_confirmation: "Different1!")
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end

    it "enforces unique email" do
      create(:user, email: "uniq@example.com")
      user = build(:user, email: "uniq@example.com")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end
  end

  describe "profile_photo validations" do
    it "rejects non-image types" do
      user = build(:user)
      # attach a non-image via ActiveStorage fixture
      user.profile_photo.attach(io: StringIO.new("notimage"), filename: "text.txt", content_type: "text/plain")
      expect(user).not_to be_valid
      expect(user.errors[:profile_photo]).to include("must be a JPG or PNG")
    end

    it "rejects large images" do
      user = build(:user)
      # build a fake large file by stubbing byte_size
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new("0" * 3.megabytes),
        filename: "large.png",
        content_type: "image/png"
      )
      user.profile_photo.attach(blob)
      expect(user).not_to be_valid
      expect(user.errors[:profile_photo]).to include("is too big (max 2MB)")
    end

    it "accepts a valid image" do
      user = build(:user)
      user.profile_photo.attach(
        io: File.open(Rails.root.join("spec", "fixtures", "files", "avatar.png")),
        filename: "avatar.png",
        content_type: "image/png"
      )
      expect(user).to be_valid
    end
  end
end
