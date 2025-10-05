require 'rails_helper'

RSpec.describe Company, type: :model do
  it 'is invalid without a name' do
    company = Company.new(name: nil, website: 'https://example.com')
    expect(company).not_to be_valid
    expect(company.errors[:name]).to include("can't be blank")
  end

  it 'is invalid without a website' do
    company = Company.new(name: 'NoWeb', website: nil)
    expect(company).not_to be_valid
    expect(company.errors[:website]).to include("can't be blank")
  end

end
