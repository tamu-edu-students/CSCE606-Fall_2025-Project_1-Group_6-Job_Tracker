require 'rails_helper'

RSpec.describe Company, type: :model do
  it 'is invalid without a name' do
    company = Company.new(name: nil, website: 'https://example.com')
    expect(company).not_to be_valid
    expect(company.errors[:name]).to include("can't be blank")
  end

  it 'is invalid with an improperly formatted website' do
    company = Company.new(name: 'BadURL', website: 'not_a_url')
    expect(company).not_to be_valid
    expect(company.errors[:website]).to include("must be a valid URL starting with http:// or https://")
  end

  it 'is valid when website is blank' do
    company = Company.new(name: 'BlankWeb', website: '')
    expect(company).to be_valid
  end

  it 'is valid with a properly formatted website' do
    company = Company.new(name: 'GoodURL', website: 'https://example.com')
    expect(company).to be_valid
  end
end
