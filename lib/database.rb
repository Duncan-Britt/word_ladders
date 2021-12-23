# frozen_string_literal: true

require 'bcrypt'
require 'pg'

DB_NAME = ENV['database'] || 'word_ladders'

module Database
  @psql = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG::Connection.open(:dbname => DB_NAME)
          end

  def self.connection
    return @psql
  end

  def self.add_puzzle(ladder, user_id: 0) # AI user id is 0, since first user is 1
    puzzle_id = nil

    unless duplicate?(ladder)
      sql = 'INSERT INTO puzzles (first, last, length) VALUES ($1, $2, $3);'

      Database.connection.exec_params(
        sql, [ladder.first, ladder.last, ladder.length]
      )
    end

    sql = <<~SQL
    SELECT id
    FROM puzzles
    WHERE first = $1 AND last = $2 AND length = $3
    SQL

    puzzle_id = Database.connection.exec_params(
      sql, [ladder.first, ladder.last, ladder.length]
    ).values[0][0].to_i

    # INSERT SOLUTION INTO DB
    sql= 'INSERT INTO solutions (solution, user_id, puzzle_id) VALUES($1, $2, $3)'

    words = PG::TextEncoder::Array.new.encode(ladder.words)
    Database.connection.exec_params(
      sql, [words, user_id, puzzle_id]
    )

    puzzle_id
  end

  module Users
    def self.leader_board_position(user_id)
      sql = <<~SQL
        SELECT leader_board_position FROM (
          SELECT
          id,
          RANK() OVER ( ORDER BY n_solved DESC ) leader_board_position
          FROM users
        ) as user_ranks
        WHERE id = $1;
      SQL

      Database.connection.exec_params(sql, [user_id.to_i]).values[0][0]
    end

    def self.submit_solution(user_id, puzzle_id, solution)
      sql = <<~SQL
        UPDATE users
        SET n_solved = n_solved + 1
        WHERE id = $1;
      SQL

      Database.connection.exec_params(sql, [user_id.to_i])

      sql= <<~SQL
        INSERT INTO solutions (solution, user_id, puzzle_id)
                        VALUES($1, $2, $3)
      SQL

      solution = PG::TextEncoder::Array.new.encode(solution)
      Database.connection.exec_params(sql, [solution, user_id, puzzle_id])
    end

    def self.auth(input_username, input_password)
      sql = 'SELECT id, password_digest FROM users WHERE display_name = $1'
      db_id, db_pass = Database.connection.exec_params(sql,
        [input_username]).values[0]
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
      Database.connection.exec_params(sql, [input_username, password])

      sql = 'SELECT id FROM users WHERE display_name = $1;'
      Database.connection.exec_params(sql, [input_username]).values[0][0]
    end

    def self.delete_account(input_username, input_password)
      db_id = self.auth(input_username, input_password)
      return false unless db_id
      sql = 'DELETE FROM users WHERE id = $1;'
      res = Database.connection.exec_params(sql, [db_id])
      res.cmd_status == 'DELETE 1'
    end

    def self.account_exists?(username)
      sql = 'SELECT id FROM users WHERE display_name = $1'
      Database.connection.exec_params(sql, [username]).values[0]
    end

    def self.update_username(id, new_username)
      sql = <<~SQL
        UPDATE users
        SET display_name = $1
        WHERE id = $2
      SQL
      Database.connection.exec_params(sql, [new_username, id])
    end

    def self.update_password(id, input_password)
      sql = <<~SQL
        UPDATE users
        SET password_digest = $1
        WHERE id = $2
      SQL
      new_password = BCrypt::Password.create(input_password)
      Database.connection.exec_params(sql, [new_password, id])
    end

    def self.solutions(user_id)
      sql = <<~SQL
        SELECT solutions.solution,
               puzzles.first,
               puzzles.last,
               puzzles.length
        FROM solutions
        INNER JOIN puzzles ON (puzzles.id = solutions.puzzle_id)
        INNER JOIN users ON (solutions.user_id = users.id)
        WHERE user_id = $1;
      SQL

      puzzles = []
      res = Database.connection.exec_params(sql, [user_id])
      res.each do |puzzle|
        puzzle["solution"] = PG::TextDecoder::Array.new.decode(puzzle["solution"])
        puzzles << puzzle
      end
      puzzles
    end

    def self.top_100
      sql = <<~SQL
        SELECT
        display_name,
        leader_board_position FROM (
                  SELECT
                  id,
                  display_name,
                  RANK() OVER ( ORDER BY n_solved DESC ) leader_board_position
                  FROM users
                ) as user_ranks
        WHERE id != 0
        LIMIT 100;
      SQL

      Database.connection.exec_params(sql).values
    end
  end

  class << self
    private

    def duplicate?(ladder)
      sql = <<~SQL
      SELECT COUNT(id)
      FROM puzzles
      WHERE first = $1 AND last = $2 AND length = $3
      GROUP BY id;
      SQL


      Database.connection.exec_params(
        sql, [ladder.first, ladder.last, ladder.length]
      ).values.length != 0
    end
  end
end
