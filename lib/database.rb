# frozen_string_literal: true

require 'bcrypt'
require 'pg'

DB_NAME = ENV['database'] || 'user_test_pass'

module Database
  @psql = PG::Connection.open(:dbname => DB_NAME)

  def self.auth(input_username, input_password)
    sql = 'SELECT id, password_digest FROM users WHERE display_name = $1'
    db_id, db_pass = @psql.exec_params(sql, [input_username]).values[0]
    if db_id
      BCrypt::Password.new(db_pass) == input_password ? db_id : false
    else
      false
    end
  end

  def self.new_user(input_username, input_password)
    return false if self.account_exists?(input_username)
    sql = 'INSERT INTO users (display_name, password_digest) VALUES ($1, $2);'
    password = BCrypt::Password.create(input_password)
    @psql.exec_params(sql, [input_username, password])
    true
  end

  def self.delete_account(input_username, input_password)
    db_id = self.auth(input_username, input_password)
    return false unless db_id
    sql = 'DELETE FROM users WHERE id = $1;'
    @psql.exec_params(sql, [db_id])
    true
  end

  def self.account_exists?(username)
    sql = 'SELECT id FROM users WHERE display_name = $1'
    @psql.exec_params(sql, [username]).values[0]
  end

  def self.update_username(id, new_username)
    sql = <<~SQL
      UPDATE users
      SET display_name = $1
      WHERE id = $2
    SQL
    @psql.exec_params(sql, [new_username, id])
  end

  def self.update_password(id, input_password)
    sql = <<~SQL
      UPDATE users
      SET password_digest = $1
      WHERE id = $2
    SQL
    new_password = BCrypt::Password.create(input_password)
    @psql.exec_params(sql, [new_password, id])
  end

  # class << self
  #   private
  #
  #   def account_exists?(username)
  #     sql = 'SELECT id FROM users WHERE display_name = $1'
  #     @psql.exec_params(sql, [username]).values[0]
  #   end
  # end
end

# p Database.auth('freddieReady', 'abcdefg')
# Database.new_user("bob96", "123456")
# p Database.delete_account("bob96", "123456")
