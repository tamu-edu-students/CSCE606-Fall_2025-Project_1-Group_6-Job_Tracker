# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Job.destroy_all
Company.destroy_all
User.destroy_all

user = User.create!(
  full_name: "TestUser",
  email: "test@example.com",
  password: "Password1#",
  password_confirmation: "Password1#",
  phone: "1234567890",
  location: "College Station, TX",
  profile_completed: true
)

# Create some companies
google = Company.create!(name: "Google", website: "https://google.com")
amazon = Company.create!(name: "Amazon", website: "https://amazon.com")
openai = Company.create!(name: "OpenAI", website: "https://openai.com")

# Create some jobs for the user
Job.create!(
  title: "Software Engineer",
  link: "https://careers.google.com/jobs/123",
  deadline: Date.today + 30,
  status: "Applied",
  user: user,
  company: google
)

Job.create!(
  title: "Backend Developer",
  link: "https://amazon.jobs/jobs/456",
  deadline: Date.today + 15,
  status: "Interview",
  user: user,
  company: amazon
)

Job.create!(
  title: "Research Intern",
  link: "https://openai.com/careers/789",
  deadline: Date.today + 45,
  status: "Offer",
  user: user,
  company: openai
)
