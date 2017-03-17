# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_workflow_session',
  :secret      => '570a0248b139b45d2007980b525dfd4425593f7316abdd5403a61b731878ac286c0bba75afc22789005b088ceaa46d1a0d0a421ec8f79690d6c919996e1fb282'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
