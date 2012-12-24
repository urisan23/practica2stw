require 'sinatra'
require 'haml'

#use Rack::Session::Pool, :expire_after => 2592000
set :session_secret, ENV["SESSION_KEY"] || 'too secret'

configure do
  enable :sessions
end

before do
  @defeat = { rock: :scissors, paper: :rock, scissors: :paper}
  @throws = @defeat.keys
  @score = {win: 0, tie: 0, lose: 0}
end

get '/' do
  if session[:win] == nil 
    session[:win] = 0
    session[:tie] = 0
    session[:lose] = 0  
  end
  haml :index
end

get '/clear' do
  session.clear
  redirect '/'
end

get '/throw/' do
	@option = params['option'.to_sym].downcase
	@player_throw = @option.to_sym

  halt(403, "Debes seleccionar una de las siguientes opciones: '#{@throws.join(', ')}'") unless @throws.include? @player_throw

  @computer_throw = @throws.sample

  if @player_throw == @computer_throw 
    @answer = "Se ha producido un empate."
    @score[:tie] += 1
    session[:tie] += 1
  elsif @player_throw == @defeat[@computer_throw]
    @answer = "El ordenador gana; #{@computer_throw} derrota a #{@player_throw}."
    @score[:lose] += 1
    session[:lose] += 1
  else
    @answer = "Muy bien. #{@player_throw} vence a #{@computer_throw}."
    @score[:win] += 1
    session[:win] += 1
  end
  haml :resultado
end
