require "sinatra"
require "sinatra/reloader" if development?
require 'sinatra/content_for'
require "tilt/erubis"
require 'json'
require_relative 'word_ladder'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

before do
  init_test_words
  session[:ladder] ||= WordLadder.new
  session[:steps] ||= []
  session[:dark] == 1
  p session[:ladder]
end

helpers do

end

def valid_step?(step)
  @test_words.include?(step)
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

def matches_last?(word)
  return adjacent?(session[:ladder].last, word)
end

def init_test_words
  words = File.readlines('./cmudict.dict.txt').map do |line|
    if data = line.match(/^[a-z]+\b/)
      data.to_s
    else
      nil
    end
  end

  words.select! { |word| word }
  words.map! { |word| word.downcase }
  words.uniq!

  @test_words = words
end

get '/' do
  @ladder = session[:ladder]
  @steps = session[:steps]
  @dark = session[:dark]
  erb :home, layout: :layout
end

post '/' do
  step = params[:word]
  if valid_step?(step)
    if matches_last?(step)
      session[:solved] = true
    end
    session[:steps].push(step)
  else
    session[:error] = "That doesn't appear to be a word."
  end
  redirect '/'
end

post '/step_back' do
  session[:steps] = session[:steps][0..-2]
  status 204
end

post '/toggle_dark_mode' do
  session[:dark] ^= 1
  status 204
end

post '/new_puzzle' do
  session[:ladder] = WordLadder.new
  session[:steps] = []
  session[:solved] = false
  redirect '/'
end
