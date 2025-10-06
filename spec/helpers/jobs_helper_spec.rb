require 'rails_helper'

RSpec.describe JobsHelper, type: :helper do
  describe "#status_badge" do
    it "returns the correct badge for 'applied'" do
      expect(helper.status_badge("applied")).to include("📩 Applied")
    end

    it "returns the correct badge for 'interview'" do
      expect(helper.status_badge("interview")).to include("📞 Interview")
    end

    it "returns the correct badge for 'offer'" do
      expect(helper.status_badge("offer")).to include("✅ Offer")
    end

    it "returns the correct badge for 'rejected'" do
      expect(helper.status_badge("rejected")).to include("❎ Rejected")
    end

    it "handles mixed-case and whitespace statuses" do
      expect(helper.status_badge("  Applied  ")).to include("📩 Applied")
    end

    it "returns 'Unknown' for unrecognized statuses" do
      expect(helper.status_badge("invalid")).to include("Unknown")
    end
  end

  describe "#next_direction" do
    it "toggles from asc to desc for same column" do
      expect(helper.next_direction("title", "title", "asc")).to eq("desc")
    end

    it "toggles from desc to asc for same column" do
      expect(helper.next_direction("title", "title", "desc")).to eq("asc")
    end

    it "defaults to asc for a different column" do
      expect(helper.next_direction("company", "title", "desc")).to eq("asc")
    end
  end

  describe "#sort_indicator" do
    it "returns ↑ for ascending sort" do
      expect(helper.sort_indicator("title", "title", "asc")).to eq("↑")
    end

    it "returns ↓ for descending sort" do
      expect(helper.sort_indicator("title", "title", "desc")).to eq("↓")
    end

    it "returns empty string when column is not current sort" do
      expect(helper.sort_indicator("company", "title", "asc")).to eq("")
    end
  end
end
