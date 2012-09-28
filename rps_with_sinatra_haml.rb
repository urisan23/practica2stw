require 'sinatra'
require 'erb'

# before we process a route we'll set the response as plain text
# and set up an array of viable moves that a player (and the
# computer) can perform

configure do
	enable :sessions			# indicar persistencia!!! (cuanto duran las variables: la sesion, el coockie o hasta que se apague el servidors)
end

helpers do
	include Rack::Utils
	alias_method :h, :escape_html
end

before do
  @defeat = {rock: :scissors, paper: :rock, scissors: :paper}
  @throws = @defeat.keys
  session[:ties] = "0"
end

get '\/' do
	session[:value] = "-1" if session[:value].nil?
	session[:value] = (session[:value].to_i + 1).to_s
	@counter_total = session[:value]
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
	 @counter_ties = session[:ties];
  elsif @player_throw == @defeat[@computer_throw]
    @answer = "Computer wins; #{@computer_throw} defeats #{@player_throw}"
  else
    @answer = "Well done. #{@player_throw} beats #{@computer_throw}"
  end
  erb :index
end
