FactoryBot.define do
  factory :reminder do
    association :user
    association :job
    reminder_type { "deadline" }
    reminder_time { 3.days.from_now }
    disabled { false }
    notified { false }
  end
end
