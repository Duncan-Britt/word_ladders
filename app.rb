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

def matches_last?(word)
  return WordGraph.adjacent?(session[:ladder].last, word)
end

def last_step?
  session[:steps].length === session[:ladder].length - 3
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

get '/reveal_solutions' do
  @ladder = session[:ladder]
  erb :solutions, layout: :layout
end

post '/' do
  step = params[:word]

  if valid_step?(step)
    session[:solved] = true if matches_last?(step)

    if last_step?
      if session[:solved]
        session[:steps].push(step)
      else
        session[:error] = "The last step must also match the end word"
      end
    else
      session[:steps].push(step)
    end
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
