require 'rails_helper'

RSpec.describe Job, type: :model do
  let(:user) { User.create!(email: 'user@example.com', password: 'password') }
  let(:company) { Company.create!(name: 'TestCo', website: 'https://testco.com') }

  it 'is valid with valid attributes' do
    job = Job.new(title: 'Developer', company: company, user: user, link: 'https://job.com', deadline: Date.today + 7, notes: 'Remote', status: 'applied')
    expect(job).to be_valid
  end

  it 'is invalid without a title' do
    job = Job.new(company: company, user: user)
    expect(job).not_to be_valid
  end

  it 'belongs to a user' do
    assoc = described_class.reflect_on_association(:user)
    expect(assoc.macro).to eq :belongs_to
  end

  it 'belongs to a company' do
    assoc = described_class.reflect_on_association(:company)
    expect(assoc.macro).to eq :belongs_to
  end
end
