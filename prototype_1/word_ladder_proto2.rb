require 'pg'

DATABASE = PG.connect(dbname: "words")
MAX_LENGTH = 10
# FOUR_LETTER_WORDS = %w(hull hill hell hall bell ball bill full fill fell)

class WordSet
  attr_reader :words

  def initialize(word_length)
    sql = <<~SQL
      SELECT word FROM words5000
      WHERE length = $1
    SQL

    @words = DATABASE.exec_params(sql, [word_length]).column_values(0)
  end

  def delete_random
    self.words.delete_at(random_index)
  end

  def delete_at(index)
    self.words.delete_at(index)
  end

  def random_index
    (rand * (self.words.length - 1)).round
  end

  def length
    self.words.length
  end

  def shuffle!
    @words.shuffle!
  end

  def [](index)
    self.words[index]
  end
end

class WordLadder
  def adjacent?(word, other)
    return false if word.length != other.length

    different_chr_count = 0
    i = 0
    while (i < word.length) do
      if word[i] != other[i]
        different_chr_count += 1
      end

      return false if different_chr_count > 1

      i += 1
    end

    different_chr_count === 1
  end

  def initialize(word_length)
    @set = WordSet.new(word_length);
    @words = [@set.delete_random]

    until @words.length == MAX_LENGTH do
      break unless add_word
    end

    remove_instance_variable(:@set)
  end

  def [](index)
    self.words[index]
  end

  private

  attr_reader :words

  def add_word
    @set.shuffle!
    idx = 0
    found = false
    loop do
      break if idx == @set.length

      next_word = @set[idx]

      if not_adjacent_to_any?(self.words[0..-2], next_word)
        if adjacent?(self.words.last, next_word)
          found = true
          break
        end

        idx += 1
      else
        @set.delete_at(idx)
      end
    end

    if found
      word = @set.delete_at(idx)
      self.words.push word
    else
      return nil
    end
  end

  def not_adjacent_to_any?(previous, word)
    !previous.any? { |e| adjacent?(e, word) }
  end
end

ladder = WordLadder.new(4)
p ladder
