ENV['database'] = 'mock_word_ladder_db'

require "minitest/autorun"
require 'minitest/reporters'
Minitest::Reporters.use!

require_relative '../lib/database'

class DatabaseTest < Minitest::Test
  # def setup
  #   @valid_user = 'bobby_fischer'
  #   @valid_pass = 'knight2E4'
  #   Database.new_user(@valid_user, @valid_pass)
  # end
  #
  # def teardown
  #   Database.delete_account(@valid_user, @valid_pass)
  # end

  def test_signup_and_delete
    assert Database.new_user('new_username', '123456')
    assert Database.auth('new_username', '123456')
    assert Database.delete_account('new_username', '123456')
    refute Database.auth('new_username', '123456')
  end

  def test_auth
    @valid_user = 'bobby_fischer'
    @valid_pass = 'knight2E4'
    Database.new_user(@valid_user, @valid_pass)
    assert Database.auth(@valid_user, @valid_pass)
    refute Database.auth('invalid', 'credentials')
    Database.delete_account(@valid_user, @valid_pass)
  end
end
