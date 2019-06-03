# Bunq::Client

The `Bunq::Client` is a ruby wrapper of the [bunq Public API](https://doc.bunq.com) extracted from [Jortt Online boekhouden](https://www.jortt.nl).

The `Bunq::Client` is the main interface which can be used to navigate to other resources. The response objects are just
hashes similar to the documentation of the bunq API. Only the content of `Response` is returned.

The bunq [Pagination](https://doc.bunq.com/api/1/page/pagination) is implemented using a ruby `Enumerator`. 
All `index` methods are `Paginated`. This means you can loop through large resultsets without loading
everything into memory.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bunq-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bunq-client

### One time setup

1) Create installation
```ruby

# Generate keys on the fly. Make sure you save these keys in a secure location.
# Alternatively use keys already generated.
openssl_key = OpenSSL::PKey::RSA.new(2048)
public_key = openssl_key.public_key.to_pem
private_key = openssl_key.to_pem

Bunq.configure do |config|
  config.api_key = 'YOUR API KEY'
  config.private_key = private_key
  config.server_public_key = nil # you don't have this yet
  cofig.installation_token = nil # this MUST be nil for creating installations
end

# Create the installation
installation = Bunq.client.installations.create(public_key)

# Print the installation token to put in your Bunq::Configuration
installation_token = installation[1]['Token']['token']
puts "config.installation_token = #{installation_token}"

# Keep the public key to put in your Bunq::Configuration
server_public_key_location = "./server_public_key.pub"
File.open(server_public_key_location, 'w') { |file| file.write(installation[2]['ServerPublicKey']['server_public_key']) }
puts "config.server_public_key written to file #{server_public_key_location}"
```

2) Register your device as device server 
This is typically your application server (or your laptop when playing around).

```ruby
Bunq.configure do |config|
  config.api_key = 'YOUR API KEY'
  # Used for request signing
  config.private_key = 'SAME PRIVATE KEY AS IN STEP 1'
  # Used for response verification
  config.server_public_key = 'THE CONTENTS OF THE PUBLIC KEY FILE RETURNED IN STEP 1'
  cofig.installation_token = 'THE INSTALLATION TOKEN RETURNED IN STEP 1'
end

response = Bunq.client.device_servers.create('My Laptop')
puts "Device server created: #{response[0]['Id']['id']}"
```

3) Optional: Pin certificate (if you want to receive callbacks)
```ruby
Bunq.configure do |config|
  config.api_key = 'YOUR API KEY'
  # Used for request signing
  config.private_key = 'SAME PRIVATE KEY AS IN STEP 1'
  # Used for response verification
  config.server_public_key = 'THE CONTENTS OF THE PUBLIC KEY FILE RETURNED IN STEP 1'
  cofig.installation_token = 'THE INSTALLATION TOKEN RETURNED IN STEP 1'
end

certificate_of_you_callback_url = IO.read('path_to_pem_file')
Bunq.client.me_as_user.certificate_pinned.create(certificate_of_you_callback_url)
```

4) Optional: Register callback url (for realtime updates of e.g. payments)
```ruby
Bunq.configure do |config|
  config.api_key = 'YOUR API KEY'
  # Used for request signing
  config.private_key = 'SAME PRIVATE KEY AS IN STEP 1'
  # Used for response verification
  config.server_public_key = 'THE CONTENTS OF THE PUBLIC KEY FILE RETURNED IN STEP 1'
  cofig.installation_token = 'THE INSTALLATION TOKEN RETURNED IN STEP 1'
end

Bunq.client.me_as_user_company.update(
  notification_filters: [{
    "notification_delivery_method": "URL",
    "notification_target": 'https://YOUR_CALLBACK_URL',
    "category": "PAYMENT"
  }]
)
```

## Usage

```ruby
Bunq.configure do |config|
  
  # Mandatory configuration after inital setup phase
  config.api_key = 'YOUR API KEY' 
  # Private key used for request signing
  config.private_key = 'YOUR PRIVATE KEY'
  # Public key from bunq retrieved via Bunq.client.installations.create
  config.server_public_key = 'SERVER PUBLIC KEY'
  # Installation token retrieved via Bunq.client.installations.create
  config.installation_token = 'YOUR INSTALLATION TOKEN'

  
  # Optional configuration for access to the sandbox
  # config.sandbox = true 
  # if config.sandbox
  #  config.sandbox_user = 'USER'
  #  config.sandbox_password = 'PASSWORD'
  # end
end

# List id's of all your monetary_accounts
Bunq.client.me_as_user.monetary_accounts.index.each do |monetary_account|
  puts monetary_account['MonetaryAccountBank']['id']
end
```

## Session caching

By default, each `Bunq.client` creates a new session. If you want to share a session between multiple
`Bunq.client`s, use the following configuration:

```
Bunq.configure do |config|
  config.session_cache = Bunq::ThreadSafeSessionCache.new
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jorttbv/bunq-client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

