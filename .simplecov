# .simplecov
SimpleCov.start 'rails' do
  # Ignore base classes that are tested indirectly
  add_filter 'app/jobs/application_job.rb'
  add_filter 'app/mailers/application_mailer.rb'
  add_filter 'app/channels/application_cable/' # Also a good one to ignore
end
