# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader" if development?
require 'sinatra/content_for'
require "tilt/erubis"
require "bcrypt"
require "pg"
require 'json'

require_relative './lib/database'
require_relative './lib/word_ladder.rb'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

before do
  session[:dark] == 1
  init_test_words
  session[:ladder] ||= init_ladder
  session[:steps] ||= []
  p session[:ladder]
end

def init_ladder
  ladder = WordLadder.new

  session[:puzzle_id] = Database.add_puzzle(ladder)
  return ladder
end

def init_test_words
  words = File.readlines('./data/cmudict.txt').map do |line|
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

def is_a_word?(word)
  @test_words.include?(word)
end

def ladder_complete?
  WordLadder.adjacent?(session[:steps].last, session[:ladder].last)
end

def submit_solution
  first = session[:ladder].first
  last = session[:ladder].last
  solution = [first] + session[:steps] + [last]
  Database::Users.submit_solution(session[:user_id], session[:puzzle_id], solution)
end

get '/' do
  redirect '/play'
end

get '/about' do
  # erb :about, layout: :layout
  redirect 'https://github.com/Duncan-Britt/word_ladders#readme'
end

get '/contact' do
  # erb :contact, layout: :layout
  redirect 'https://github.com/Duncan-Britt'
end

get '/leaderboard' do
  @leaderboard = Database::Users.top_100
  erb :leaderboard, layout: :layout
end

get '/play' do
  if session[:complete_ladder]
    redirect '/play/victory'
  end
  @dark = session[:dark]
  @first = session[:ladder].first
  @last = session[:ladder].last
  @length = session[:ladder].length
  erb :play, layout: :layout
end

get '/play/victory' do
  session[:dark]
  @first = session[:ladder].first
  @last = session[:ladder].last
  @length = session[:ladder].length
  erb :victory, layout: :layout
end

get '/new_game' do
  session[:complete_ladder] = false
  session[:unlocked] = false
  session[:ladder] = init_ladder
  session[:steps] = []
  redirect '/play'
end

get '/account/solutions' do
  @puzzles = Database::Users.solutions(session[:user_id])
  erb :user_solutions, layout: :layout
end

get '/solutions/:puzzle_id' do
  session[:unlocked] = true
  erb :solutions, layout: :layout
end

get '/login' do
  erb :login, layout: :layout
end

post '/login' do
  input_username = params[:username]
  input_password = params[:password]
  if (session[:user_id] = Database::Users.auth(input_username, input_password))
    session[:username] = input_username
    session[:success] = "You have been logged in successfully"
    redirect '/'
  else
    session[:error] = "The username or password you enterd was incorrect"
    erb :login, layout: :layout
  end
end

post '/account' do
  input_username = params[:username]
  input_password = params[:password]
  if (session[:user_id] = Database::Users.new_user(input_username, input_password))
    session[:username] = input_username
    session[:success] = "Account created successfully. You are logged in"
    redirect '/'
  else
    session[:error] = "That username is taken. Try another"
    redirect '/login'
  end
end

get '/logout' do
  session.delete(:user_id)
  session.delete(:username)
  redirect '/play'
end

get '/account' do
  redirect '/play' unless session[:user_id]

  @ldr_brd_n = Database::Users.leader_board_position(session[:user_id])
  erb :account, layout: :layout
end

get '/account/edit/username' do
  redirect '/play' unless session[:user_id]

  erb :edit_username, layout: :layout
end

get '/account/edit/password' do
  redirect '/play' unless session[:user_id]

  erb :edit_password, layout: :layout
end

delete '/account' do
  return unless session[:user_id]

  input_username = params[:username]
  input_password = params[:password]
  if session[:username] == input_username &&
     Database::Users.delete_account(input_username, input_password)

    session.delete(:user_id)
    session.delete(:username)
    session[:success] = "Your account has been deleted"
    status 301
    JSON.generate({ path: '/play' })
  else
    status 401
  end
end

post '/step' do
  input_word = params[:step]
  if is_a_word?(input_word)
    session[:steps].push(input_word)

    if ladder_complete?
      submit_solution if session[:user_id] && !session[:unlocked]
      session[:complete_ladder] = true
      session[:success] = "Solved! Great Work!"
      status 301
      JSON.generate({ path: '/play/victory' })
    else
      @first = session[:ladder].first
      @last = session[:ladder].last
      status 201
      erb :ladder, layout: false
    end
  else
    status 204
  end
end

delete '/step' do
  session[:steps].pop
  @first = session[:ladder].first
  @last = session[:ladder].last
  status 201
  erb :ladder, layout: false
end

put '/username' do
  return unless session[:user_id]

  input_username = params[:new_username]
  if Database::Users.account_exists?(input_username)
    status 403
    "Sorry, that username is taken"
  else
    res = Database::Users.update_username(session[:user_id], input_username)
    if res.cmd_status == "UPDATE 1"
      session[:username] = input_username
      session[:success] = "Username updated successfully"
      status 204
    else
      p "error"
    end
  end
end

put '/password' do
  return unless session[:user_id]

  input_password = params[:new_password]
  res = Database::Users.update_password(session[:user_id], input_password)
  if res.cmd_status == "UPDATE 1"
    session[:success] = "Password updated successfully"
    status 204
  else
    raise StandarError.new("Datbase not updated properly: #{res.cmd_status}")
  end
end

put '/toggle_dark_mode' do
  session[:dark] ^= 1
  status 204
end

not_found do
  redirect '/play'
end
