FactoryBot.define do
  factory :reminder do
    job { nil }
    user { nil }
    reminder_type { "MyString" }
    reminder_time { "2025-10-06 05:36:21" }
    notified { false }
    disabled { false }
  end
end
