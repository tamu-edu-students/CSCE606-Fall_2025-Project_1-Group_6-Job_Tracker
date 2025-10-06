# spec/support/active_storage.rb
RSpec.configure do |config|
  config.after(:each) do
    # Cleanup ActiveStorage test files
    ActiveStorage::Blob.all.each(&:purge_later)
  end
end
