FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "ExampleCo #{n}" }
    website { "https://www.example.com" }
  end
end
