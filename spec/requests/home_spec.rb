# spec/requests/home_spec.rb
require 'rails_helper'

RSpec.describe "HomeController", type: :request do
  describe "GET /" do
    it "returns a successful response and renders the index template" do
      # Make a GET request to the root URL of your application
      get root_path

      # 1. Check for a successful HTTP 200 OK status
      expect(response).to have_http_status(:success)

      # 2. Check that it rendered the 'index' template
      expect(response).to render_template(:index)

      # 3. (Optional but recommended) Check for some text in the page body
      #    Replace this with actual text from your app/views/home/index.html.erb
      expect(response.body).to include("Track Your Job Applications Effortlessly")
    end
  end
end
