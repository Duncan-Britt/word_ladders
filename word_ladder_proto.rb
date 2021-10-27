FOUR_LETTER_WORDS = %w(hull hill hell hall bell ball bill)

set = FOUR_LETTER_WORDS.dup;

ladder = []

def random_index(array)
  (rand * (array.length - 1)).round
end

word = set.delete_at(random_index(set))

ladder.push word

idx = nil

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

# p adjacent?('hell', 'hall') === true
# p adjacent?('hell', 'halloween') === false
# p adjacent?('hill', 'hell') === true
# p adjacent?('hilly', 'hill') === false
# p adjacent?('hill', 'hill') === false

def not_adjacent_to_any?(previous, word)
  !previous.any? { |e| adjacent?(e, word) }
end

start_idx = random_index(set)
idx = start_idx

loop do
  next_word = set[idx]
  break if adjacent?(ladder.last, next_word) &&
           not_adjacent_to_any?(ladder.slice(0, ladder.length - 1), next_word)

  idx = (idx + 1) % set.length
  break if idx == start_idx
end

word = set.delete_at(idx)
ladder.push word

start_idx = random_index(set)
idx = start_idx
not_found = false
loop do
  next_word = set[idx]
  break if adjacent?(ladder.last, next_word) &&
           not_adjacent_to_any?(ladder.slice(0, ladder.length - 1), next_word)

  p idx
  idx = (idx + 1) % set.length
  if idx == start_idx
    not_found = true
    break
  end
end

word = set.delete_at(idx)
ladder.push word unless not_found

# test = %w(hall hell)
# p adjacent?(test.last, 'bell')
# p not_adjacent_to_any?(test.slice(0, test.length - 1), 'bell')

p ladder
