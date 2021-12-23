require 'CSV'
require 'yaml'

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
      ladder = make_sub_ladder(v: v, length: length, prev: [])
      break if ladder
    end
    ladder
  end

  def make_sub_ladder(v: random_vertex, length: 3, prev: [])
    ladder = [v]
    return ladder if ladder.length == length

    neighbors = v.neighbors - prev
    neighbors.select! do |neighbor|
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
    if word.length == other.length
      different_chr_count = 0
      i = 0
      while (i < word.length)
        different_chr_count += 1 if word[i] != other[i]
        return false if different_chr_count > 1
        i += 1
      end

      return different_chr_count == 1
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

      while (j < other.length)
        return false if word[i] != other[j]
        i += 1
        j += 1
      end

      true
    else
      false
    end
  end

  def write
    data = []

    path = File.expand_path("../../data/graph.yml", __FILE__)

    File.open(path, "w") do |file|
      @vertices.each do |vertex|
        word_data = { vertex.data => vertex.neighbors.map { |n| n.data } }
        data.push(word_data)
      end

      file.write(Psych.dump(data))
    end
  end
end

common_words = CSV.parse(
  File.read(File.expand_path("../../data/english_words.csv", __FILE__)),
  headers: :first_row
).map { |row| row[1] }

common_words.map! { |word| word.downcase }
common_words.select! { |word| word.match?(/^[a-z]+$/) }
common_words.uniq!

word_graph = WordGraph.new(common_words)

word_graph.write
