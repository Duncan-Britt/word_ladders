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

  def inspect
    "data: #{@data}, neighbors: #{@neighbors.map { |n| n.data }}"
  end

  def traverse(end_point)
    return [self.data, end_point.data] if self.neighbors.include? end_point

    queue = [[self]]
    while (queue.length != 0)
      if queue.length > 1_000_000
        puts ''
        p :timeout
        puts ''
        return :timeout
      end
      path = queue.shift
      node = path[-1]
      return path.map { |n| n.data } if node == end_point

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

  def initialize()
    @vertices = []

    word_data = Psych.load_file("./data/graph.yml")

    word_data.each do |hash, _|
      word = hash.keys[0]
      add_vertex(word)
    end

    i = 0
    word_data.each do |hash|
      node = @vertices[i]
      i += 1

      hash.each do |word, adjacents|
        adjacents.each do |neighbor|
          link = find_vertex_by_data(neighbor)
          node.neighbors.push(link)
        end
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
      ladder = make_sub_ladder(v: v, length: length, prev: [])
      break if ladder
    end
    ladder.map { |v| v.data }
  end

  def make_sub_ladder(v: random_vertex, length: 3, prev: [])
    ladder = [v]
    return ladder if ladder.length == length

    neighbors = v.neighbors - prev
    neighbors.select! do |neighbor|
      prev.none? { |v| WordGraph.adjacent?(v.data, neighbor.data) }
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

  def self.adjacent?(word, other)
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

  def shortest_path(word, other)
    v = find_vertex_by_data(word)
    o = find_vertex_by_data(other)
    v.traverse(o)
  end
end

# english_words = Psych.load_file("words5k.yml")
# word_graph = WordGraph.new()
# p word_graph.shortest_path("past", "not")
# p 'here!!'
# p word_graph.find_vertex_by_data('lone')
# p word_graph.make_puzzle(20)
# p word_graph.random_vertex
