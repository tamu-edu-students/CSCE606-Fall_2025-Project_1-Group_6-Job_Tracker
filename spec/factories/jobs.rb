FactoryBot.define do
  factory :job do
    sequence(:title) { |n| "Software Engineer #{n}" }
    association :company
    link { "https://jobs.example.com/position/123" }
    deadline { 1.month.from_now.to_date }
    notes { "Applied via referral. Follow up in two weeks." }
    status { "applied" }
    association :user
  end
end
