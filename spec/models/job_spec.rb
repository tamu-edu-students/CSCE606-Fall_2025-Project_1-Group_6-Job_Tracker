require 'rails_helper'

RSpec.describe Job, type: :model do
  let(:user) { User.create!(email: 'jj@example.com', password: 'Password1!', password_confirmation: 'Password1!', full_name: 'J', phone: '+12345678901') }
  let(:company) { Company.create!(name: 'Comp', website: 'https://comp.example') }

  it 'is valid with title, user and company' do
    job = Job.new(title: 'X', user: user, company: company)
    expect(job).to be_valid
  end

  it 'is invalid without a title' do
    job = Job.new(title: nil, user: user, company: company)
    expect(job).not_to be_valid
    expect(job.errors[:title]).to include("can't be blank")
  end

  it 'is invalid without a user' do
    job = Job.new(title: 'T', user: nil, company: company)
    expect(job).not_to be_valid
  end

  it 'is invalid without a company' do
    job = Job.new(title: 'T', user: user, company: nil)
    expect(job).not_to be_valid
  end
end
