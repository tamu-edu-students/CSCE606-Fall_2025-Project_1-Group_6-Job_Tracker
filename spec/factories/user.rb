FactoryBot.define do
  factory :user do
    sequence(:full_name) { |n| "Test User #{n}" }
    sequence(:email)     { |n| "user#{n}@example.com" }
    phone { "+12345678901" }
    password { "Passw0rd!" }
    password_confirmation { "Passw0rd!" }

    # Your image version
    trait :with_image do
      after(:build) do |user|
        user.profile_photo.attach(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "avatar.png")),
          filename: "avatar.png",
          content_type: "image/png"
        )
      end
    end

    # Malvika's user for testing
    trait :simple do
      full_name { "Test User" }
      email { Faker::Internet.email }
      phone { "1234567890" }
      password { "Password@123" }
      password_confirmation { "Password@123" }
    end
  end
end
