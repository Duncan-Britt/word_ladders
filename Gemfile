source "https://rubygems.org"

ruby '2.7.2'
gem "sinatra", "~>2.1.0"
gem "sinatra-contrib"
gem "erubis"
gem "bcrypt"
gem "pg"
gem 'rake'
gem 'rubocop', '~> 1.2.0', groups: [:development, :test]

group :production do
  gem "puma"
end

group :test do
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'rack-test'
end
