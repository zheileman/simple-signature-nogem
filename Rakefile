require 'rubygems'
require 'bundler'
require 'logger'
require_relative 'lib/simple_signature'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'rspec/core/rake_task'

task :default => :spec
task :test => :spec

desc "Run all specs"
RSpec::Core::RakeTask.new('spec') do |spec|
  spec.rspec_opts = %w{}
end

def init_keystore!
  SimpleSignature.configure do |config|
    config.init_keystore({ 'mykey' => { secret: 'xxxx' } })
    config.logger = Logger.new($stdout)
  end
end


task :sign, [:key] do |t, args|
  init_keystore!
  
  key = args[:key]
  payload = args[:payload]
  
  begin
    generator = SimpleSignature::Generator.new(key) do |g|
      g.include_all({ method: 'get', path: '/test.json' })
    end

    puts generator.auth_hash
  rescue => ex
    puts "There was an error. Make sure you run this task with the only valid key available: mytest"
    puts "Example: bundle exec rake 'sign[mykey]'"
  end
end

task :validate, [:key, :signature, :timestamp] do |t, args|
  init_keystore!
  
  key = args[:key]
  signature = args[:signature]
  timestamp = args[:timestamp]
  
  validator = SimpleSignature::Validator.new(key, signature, timestamp) do |v|
    v.include_all({ method: 'get', path: '/test.json' })
  end

  puts "Success? #{validator.success?}"
end
