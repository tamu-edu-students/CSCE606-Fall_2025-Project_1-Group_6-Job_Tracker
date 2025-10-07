# spec/models/company_spec.rb
require "rails_helper"

RSpec.describe Company, type: :model do
  it "is invalid without a name" do
    c = Company.new(name: nil, website: nil)
    expect(c).not_to be_valid
    expect(c.errors[:name]).to include("can't be blank")
  end

  it "enforces case-insensitive uniqueness on name" do
    Company.create!(name: "System Co", website: nil)
    dup = Company.new(name: "system co", website: nil)
    expect(dup).not_to be_valid
    expect(dup.errors[:name].join).to match(/has already been taken/i)
  end

  it "allows blank website" do
    c = Company.new(name: "Blank Web", website: "")
    expect(c).to be_valid
  end

  it "requires a valid website format if present (http/https)" do
    c = Company.new(name: "Bad URL Co", website: "ftp://example.com")
    expect(c).not_to be_valid
    expect(c.errors[:website].join).to match(/must be a valid URL/i)
  end

  it "normalizes name with strip + titleize" do
    c = Company.create!(name: "  systemCo  ", website: nil)
    expect(c.reload.name).to eq("System Co")
  end
end
