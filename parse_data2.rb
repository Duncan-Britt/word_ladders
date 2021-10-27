# Need to use cmudictionary, 5000 words is not enough
#
# Need to allow for words of different lengths to be adjacent if one off
# - can't simply categories lists by word length
#
# SELECT * FROM words450k ORDER BY random() LIMIT 1;

require 'CSV'

words = File.readlines('./cmudict.dict.txt').map do |line|
  if data = line.match(/^[a-z]+\b/)
    data.to_s
  else
    nil
  end
end

words.select! { |word| word }
# p words.all? { |word| word.match(/^[a-z]+$/) } # true
words.map! { |word| word.downcase }
words.uniq!
# i = 0
# words.reverse_each { |word| p word; break if i == 50; i += 1 }

class Vertex
  attr_accessor :data, :neighbors, :weights

  def initialize(data)
    @data = data
    @neighbors = []
  end

  def random_neighbor
    idx = (rand * (self.neighbors.length - 1)).round
    self.neighbors[idx]
  end
end

class WordGraph
  attr_accessor :vertices

  def initialize(words)
    @vertices = []

    words.each do |word|
      add_vertex(word)
    end

    @vertices.each do |word|
      @vertices.each do |other_word|
        next if word == other_word
        next unless adjacent?(word.data, other_word.data)
        word.neighbors << other_word
      end
    end

    @vertices.select! { |v| v.neighbors.length != 0 }
  end

  def make_ladder(length)
    ladder = nil
    loop do
      v = random_vertex
      # v = find_vertex_by_data('tear')
      ladder = make_sub_ladder(v: v, length: length, prev: [])
      break if ladder
    end
    ladder
  end

  def make_sub_ladder(v: random_vertex, length: 3, prev: [])
    ladder = [v]
    # printf("TOP length: %d ladder: %s\n", length, ladder.map { |v| v.data }.to_s)
    return ladder if ladder.length == length

    neighbors = v.neighbors - prev
    neighbors.select! do |neighbor|
      # printf("prev: %s neighbor: %s\n", prev.map{|v|v.data}.to_s, neighbor.data.to_s)
      prev.none? { |v| adjacent?(v.data, neighbor.data) }
    end

    return nil if neighbors.empty?
    neighbors.shuffle!

    sub_ladder = nil
    neighbors.each do |n|
      sub_ladder = make_sub_ladder(v: n, length: length - 1, prev: ladder + prev)

      break if sub_ladder
    end

    sub_ladder && ladder + sub_ladder
  end

  def random_vertex
    idx = (rand * (self.vertices.length - 1)).round
    self.vertices[idx]
  end

  def add_vertex(data)
    @vertices << Vertex.new(data)
  end

  def find_vertex_by_data(data)
    vertices.each do |v|
      return v if v.data == data
    end
    nil
  end

  def count
    vertices.length
  end

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
end

common_words = CSV.parse(
  File.read("./english_words.csv"),
  headers: :first_row
).map { |row| row[1] }

common_words.map! { |word| word.downcase }
common_words.select! { |word| word.match?(/^[a-z]+$/) }
common_words.uniq!

word_graph = WordGraph.new(common_words[0..2000])
# v = word_graph.find_vertex_by_data('along')
# p v.neighbors.map { |n| n.data }
lad = word_graph.make_ladder(10)
p lad.map { |v| v.data }
