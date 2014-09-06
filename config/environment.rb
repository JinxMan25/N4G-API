# Load the rails application
require File.expand_path('../application', __FILE__)
config.frameworks -= [:active_record, :active_resource, :action_mailer]

# Initialize the rails application
N4gApi::Application.initialize!
