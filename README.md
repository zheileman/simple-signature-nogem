# Running the tests

❯ bundle exec rake  
Finished in 0.03081 seconds
25 examples, 0 failures


# Running the rake tasks to quickly sign and validate

❯ bundle exec rake "sign[mykey]"  
{"sigkey"=>"mykey", "signature"=>"81d947ab71a218002fa94a2f33be8101839ea418", "timestamp"=>1442756700}

❯ bundle exec rake "validate[mykey,81d947ab71a218002fa94a2f33be8101839ea418,1442756700]"  
Success? true


# Configuration

```ruby
  SimpleSignature.configure do |c|
    c.init_keystore(keys)  
    c.expiry_time = 900                   # default is 900
    c.key_param_name = 'sigkey'           # default is 'sigkey'
    c.signature_param_name = 'signature'  # default is 'signature'
    c.timestamp_param_name = 'timestamp'  # default is 'timestamp'
    c.logger = Logger.new($stdout)        # default is nil (no logger). Can be a lambda.
  end  
```

Everything is optional, but you would probably like to initialize the keystore at least.  
In `c.init_keystore(keys)` keys is a hash with n-keys and values in the format:

```ruby
  {
    'key1': { secret: 'xxxx' },
    'key2': { secret: 'yyy' }
  }
```

Full example of an initializer reading a YML file with pre-shared keys:

```ruby
file_path = File.join("config", "keystore.yml")
file_path = File.join("config", "keystore-sample.yml") unless File.exist?(file_path)

keys = YAML.load_file(file_path)

SimpleSignature.configure do |c|
   c.init_keystore(keys)
end
```

# Signing a request

Use `include_all` providing a hash to add the different parts of the request to the final payload to be signed. Example:

```ruby
generator = SimpleSignature::Generator.new(key) do |g|
  g.include_all({ method: method, path: path, params: params, body: body })
end
```

You can use the generator without a block too:

```ruby
generator = SimpleSignature::Generator.new(key)

generator.include_all({ method: method, path: path, params: params, body: body })

generator.reset!  # to clean the previous data and prepare the generator for a new signature
```

After succesfully generating a signature, you can access the relevant information needed to validate this signature in the future, with the following methods.

```ruby
generator.signature
generator.timestamp
generator.auth_hash     # a Hash containing the signature key, signature and timestamp
generator.auth_params   # a query string representation of the auth_hash, ready for inclusing in a URL query params
```

# Validating

```ruby
# This class will validate a request method, path, params and body
# A specific logger (or nil) can be provided, overwriting the one specified in SimpleSignature.configure
# A specific expiry time (in seconds) can be provided, overwriting the default (900) or the one specified in SimpleSignature.configure
validator = SimpleSignature::RequestValidator.new(request, {:logger => Rails.logger, :expiry_time => 1800})
```

```ruby
validator.success? # true or false

# In case of error (success = false)
validator.error.code
validator.error.message
```

# Brief Specification

The signature is created with the following algorithm:

```ruby
secret = 'secret'
timestamp = 1396536298  # NOW, as an integer number of seconds since the Epoch
payload = 'signable tokens' + timestamp.to_s
digest = OpenSSL::Digest::SHA1.new

hmac = OpenSSL::HMAC.hexdigest(digest, secret, payload)
```

Where 'signable tokens' for an http request, are the following:
method + path + query_string + body

Given the secret, timestamp and payload from above, the result should match: 

"e6fa248077b7dc0999f022943ba867f9ee0142e6"

For example, in the case of a GET request with some query params, 'signable tokens' will be:

Request:

`get to /api/v1.1/files/775/file_versions.xml?test=true&blah=zzz`

payload with timestamp will be: "GET/api/v1.1/files/775/file_versions.xmlblah=zzz&test=true1396536298"

Please note the verb is uppercase and the query params are ordered alphabetically, so it doesn't matter the order they are sent, the signature will always be generated based on the same order.
