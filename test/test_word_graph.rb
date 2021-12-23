require "minitest/autorun"
require 'minitest/reporters'
Minitest::Reporters.use!

require_relative '../lib/word_graph'

class DatabaseTest < Minitest::Test
  def test_adjacency
    assert WordGraph.adjacent?("busy", "abuse") == false
    assert WordGraph.adjacent?("abuse", "busy") == false
    assert WordGraph.adjacent?("buy", "busy") == true
    assert WordGraph.adjacent?("busy", "buy") == true
    assert WordGraph.adjacent?("buoy", "busy") == true
    assert WordGraph.adjacent?("busy", "buoy") == true
    assert WordGraph.adjacent?("bouy", "busy") == false
    assert WordGraph.adjacent?("abuse", "buse") == true
    assert WordGraph.adjacent?("buse", "abuse") == true
    assert WordGraph.adjacent?("buse", "abuse") == true
    assert WordGraph.adjacent?("obuse", "abuse") == true
    assert WordGraph.adjacent?("use", "bus") == false
    assert WordGraph.adjacent?("use", "buse") == true
    assert WordGraph.adjacent?("use", "user") == true
    assert WordGraph.adjacent?("user", "use") == true
    assert WordGraph.adjacent?("used", "user") == true
    assert WordGraph.adjacent?("use", "ruse") == true
    assert WordGraph.adjacent?("ruse", "use") == true
    assert WordGraph.adjacent?("fuse", "use") == true
    assert WordGraph.adjacent?("ruse", "used") == false
    assert WordGraph.adjacent?("used", "ruse") == false
    assert WordGraph.adjacent?("use", "usedd") == false
    assert WordGraph.adjacent?("usedd", "use") == false
    assert WordGraph.adjacent?("agwh", "awh") == true
    assert WordGraph.adjacent?("agwh", "akwh") == true
    assert WordGraph.adjacent?("agwh", "awhg") == false
    assert WordGraph.adjacent?("lack", "back") == true
    assert WordGraph.adjacent?("post", "pot") == true
  end
end
