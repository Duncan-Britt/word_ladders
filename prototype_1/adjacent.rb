# either they are the same length with one letter changed
#   bill
#   bell
#
# or they are the same word with +- one letter on either end
#   bell
#   bells
#
#   grunts
#   grunt
#
#    pun
#   spun

def adjacent?(word, other)
  if word.include?(other)
    word.length - 1 == other.length
  elsif other.include?(word)
    other.length - 1 == word.length
  else
    oneLetterDifference?(word, other)
  end
end

def oneLetterDifference?(word, other)
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

# p adjacent?('bill', 'bell') == true
# p adjacent?('grunts', 'grunt') == true
# p adjacent?('bill', 'bills') == true
# p adjacent?('pun', 'spun') == true
# p adjacent?('pun', 'spuns') == false
# p adjacent?('pun', 'sspun') == false
# p adjacent?('pun', 'pans') == false
# p adjacent?('pun', 'pan') == true
# p adjacent?('pun', 'pam') == false
