require 'csv'
require 'pg'

# common_words = CSV.parse(
#   File.read("./english_words.csv"),
#   headers: :first_row
# ).map { |row| row[1] }
#
# common_words.map! { |word| word.downcase }
# common_words.select! { |word| word.match?(/^[a-z]+$/) }

# might need close to all english words for validating that a given input
# from the user is in fact a word, not just gibberish

# Use common words to generate word ladders, all words to validate

# word_lists = []
#
# common_words.each do |word|
#   i = word.length
#   word_lists[i] = word_lists[i] || []
#   word_lists[i].push(word)
# end
#
# word_lists[3] # FOUR LETTER WORDS
# word_lists[4] # FOUR LETTER WORDS
#
# DATABASE = PG.connect(dbname: "words")

# word_lists.each_with_index do |list, length|
#   next if length < 2
#   next unless list
#
#   list.uniq.each do |word|
#     sql = <<~SQL
#       INSERT INTO words5000 (word, length) VALUES ($1, $2);
#     SQL
#
#     DATABASE.exec_params(sql, [word, length])
#   end
# end

# ------------------

# require 'json'
#
# all_words = JSON.parse(File.read('./words_dictionary.json')).keys
#
# word_lists = []
#
# all_words.each do |word|
#   i = word.length
#   word_lists[i] = word_lists[i] || []
#   word_lists[i].push(word)
# end

# word_lists.each_with_index { |_, length| p length }

# word_lists.each_with_index do |list, length|
#   next if length < 2
#   next unless list
#   break if length == 15
#
#   list.uniq.each do |word|
#     sql = <<~SQL
#       INSERT INTO words450k (word, length) VALUES ($1, $2);
#     SQL
#
#     DATABASE.exec_params(sql, [word, length])
#   end
# end

# ------------------------------

DATABASE = PG.connect(dbname: "words")

sql = <<~SQL
  SELECT word FROM words5000
  WHERE length = $1
SQL

four_letter_words = DATABASE.exec_params(sql, [4]).column_values(0)

p four_letter_words
