# Need to use cmudictionary, 5000 words is not enough
#
# Need to allow for words of different lengths to be adjacent if one off
# - can't simply categories lists by word length
#
# SELECT * FROM words450k ORDER BY random() LIMIT 1;

require 'yaml'

class Vertex
  attr_accessor :data, :neighbors, :weights, :parent

  def initialize(data)
    @data = data
    @neighbors = []
  end

  def random_neighbor
    idx = (rand * (self.neighbors.length - 1)).round
    self.neighbors[idx]
  end

  def traverse(end_point)
    return [self.data, end_point.data] if self.neighbors.include? end_point

    queue = [[self]]
    while (queue.length != 0)
      path = queue.shift
      node = path[-1]
      return path.map { |n| n.data } if node == end_point

      # printf("path: %s\n\n", path.map { |e| e.data }.to_s)

      node.neighbors.each do |neighbor|
        next if path.include?(neighbor)
        new_path = path.dup
        new_path << neighbor
        queue.push(new_path)
      end
    end
  end
end

class WordGraph
  attr_accessor :vertices

  def initialize(word_data)
    @vertices = []

    word_data.each do |word, _|
      add_vertex(word)
    end

    word_data.each do |word, adjacents|
      node = find_vertex_by_data(word)
      adjacents.each do |neighbor|
        link = find_vertex_by_data(neighbor)
        node.neighbors.push(link)
      end
    end
  end

  def write
    File.open("words.yml", "w") do |file|
      @vertices.each do |vertex|
        word_data = { vertex.data => vertex.neighbors.map { |n| n.data } }
        file.write(word_data.to_yaml)
      end
    end
  end

  def make_puzzle(max_length)
    ladder = make_ladder(max_length)
    shortest_path(ladder[0], ladder[-1])
  end

  def make_ladder(length)
    ladder = nil
    loop do
      v = random_vertex
      # v = find_vertex_by_data('tear')
      ladder = make_sub_ladder(v: v, length: length, prev: [])
      break if ladder
    end
    ladder.map { |v| v.data }
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

  def shortest_path(word, other)
    v = find_vertex_by_data(word)
    o = find_vertex_by_data(other)
    v.traverse(o)
  end
end

english_words = Psych.load_file("words.yml")

word_graph = WordGraph.new(english_words)

# word_graph.write
# v = word_graph.find_vertex_by_data('along')
# p v.neighbors.map { |n| n.data }
# p word_graph.make_ladder(50)
# p word_graph.shortest_path('army', 'can')
p word_graph.make_puzzle(10)
