FactoryBot.define do
  factory :user do
    full_name { "Test User" }
    email { Faker::Internet.email }
    phone { "1234567890" }
    password { "Password@123" }
    password_confirmation { "Password@123" }
  end
end
