def adjacent?(word, other)
  if word.length == other.length
    different_chr_count = 0
    i = 0
    while (i < word.length)
      different_chr_count += 1 if word[i] != other[i]
      return false if different_chr_count > 1
      i += 1
    end

    return different_chr_count === 1
  elsif word.length == other.length + 1
    i = 0
    j = 0
    while (word[i] == other[j] && i < word.length)
      i += 1
      j += 1
    end
    i += 1

    while (i < word.length)
      return false if word[i] != other[j]
      i += 1
      j += 1
    end

    true
  elsif other.length == word.length + 1
    i = 0
    j = 0
    while (word[i] == other[j] && i < word.length)
      i += 1
      j += 1
    end
    j += 1

    while (j < word.length)
      return false if word[i] != other[j]
      i += 1
      j += 1
    end

    true
  else
    false
  end
end

p adjacent? 'black', 'bloackk'
