require 'sinatra'
require 'erb'

set :session_secret, ENV["SESSION_KEY"] || 'too secret'

configure do
  enable :sessions
end

before do
  @defeat = { rock: :scissors, paper: :rock, scissors: :paper}
  @throws = @defeat.keys
  @score = { win: 0, lose: 0, ties: 0}
end

get '/' do
  if session[:win] == nil 
    session[:win] = 0
    session[:lose] = 0
    session[:ties] = 0  
  end
    erb :index
end
get '/clear' do
  session.clear
  redirect '/'
end
get '/throw/' do

  @opcion = params['option'.to_sym].downcase
  @player_throw = @opcion.to_sym

  halt(403, "You must throw one of the following: '#{@throws.join(', ')}'") unless @throws.include? @player_throw

  @computer_throw = @throws.sample

  if @player_throw == @computer_throw 
    @answer = "There is a tie"
    @score[:ties] += 1
    session[:ties] += 1

  elsif @player_throw == @defeat[@computer_throw]
    @answer = "Computer wins; #{@computer_throw} defeats #{@player_throw}"
    @score[:lose] += 1
    session[:lose] += 1

  else
    @answer = "Well done. #{@player_throw} beats #{@computer_throw}"
    @score[:win] += 1
    session[:win] += 1
  end
  erb :result
end
