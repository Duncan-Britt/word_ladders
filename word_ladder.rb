require_relative 'word_graph'

GRAPH_DEPTH_MODIFIER = 20

class WordLadder
  @@word_graph = WordGraph.new
  attr_reader :words, :length, :first, :last

  def initialize(min_size = 3, max_size = Float::INFINITY)
    @length = 0
    while @length < min_size || @length > max_size || @words == :timeout
      @words = @@word_graph.make_puzzle(GRAPH_DEPTH_MODIFIER)
      @length = @words.length
    end
    @length = @words.length
    @first = @words[0]
    @last = @words[@words.length - 1]
  end
end
