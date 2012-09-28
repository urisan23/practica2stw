require 'sinatra'
require 'erb'

# before we process a route we'll set the response as plain text
# and set up an array of viable moves that a player (and the
# computer) can perform

enable :sessions			# indicar persistencia!!! (cuanto duran las variables: la sesion, el coockie o hasta que se apague el servidors)

#use Rack::Session::Pool, :expire_after => 60

before do
  @defeat = {rock: :scissors, paper: :rock, scissors: :paper}
  @throws = @defeat.keys
end

get '\/' do
	session[:total] = "0" if session[:total].nil?
	session[:wins] = "0" if session[:wins].nil?
	session[:defeats] = "0" if session[:defeats].nil?
	session[:ties] = "0" if session[:ties].nil?
	erb :intro
end

get '/throw' do
	redirect "/throw/#{@params[:play].to_sym}"
end

get '/throw/:type?' do
  # the params hash stores querystring and form data
  halt(403, "Empty string doesn't allow!") if params[:type].nil? 

  @player_throw = params[:type].to_sym.downcase
  
  halt(403, "You must throw one of the following: '#{@throws.join(', ')}'") unless @throws.include? @player_throw
  
  @computer_throw = @throws.sample

  if @player_throw == @computer_throw 
    @answer = "There is a tie"
	 session[:ties] = (session[:ties].to_i + 1).to_s
	 
  elsif @player_throw == @defeat[@computer_throw]
    @answer = "Computer wins; #{@computer_throw} defeats #{@player_throw}"
	 session[:defeats] = (session[:defeats].to_i + 1).to_s
	 
  else
    @answer = "Well done. #{@player_throw} beats #{@computer_throw}"
	 session[:wins] = (session[:wins].to_i + 1).to_s
  end
  
  session[:total] = (session[:total].to_i + 1).to_s
  erb :index
end

get '/logout' do
	session.clear
	redirect '/'
end
