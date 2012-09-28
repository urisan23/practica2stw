require 'sinatra'
require 'erb'
require 'haml'

set :session_secret, ENV["SESSION_KEY"] || 'too secret'

# before we process a route we'll set the response as plain text
# and set up an array of viable moves that a player (and the
# computer) can perform
enable :sessions

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end
  
before do
  @defeat = { rock: :scissors, paper: :rock, scissors: :paper}
  @throws = @defeat.keys
end

get '/' do
  if session[:win] == nil
    session[:win]=0
    session[:loose]=0
    session[:tie]=0
  end
  haml :index, :locals => { :session => session }
end

get '/throw/' do
  texto = :option.to_s
  texto.gsub!(/\?*\=/, '')
  # the params hash stores querystring and form data
  @player_throw = params[texto.to_sym].to_sym

  halt(403, "You must throw one of the following: '#{@throws.join(', ')}'") unless @throws.include? @player_throw

  @computer_throw = @throws.sample

  if @player_throw == @computer_throw 
    @answer = "There is a tie"
    session[:tie] += 1
    haml :result, :locals => { :session => session }
  elsif @player_throw == @defeat[@computer_throw]
    @answer = "Computer wins; #{@computer_throw} defeats #{@player_throw}"
    session[:loose] += 1
    haml :result, :locals => { :session => session }
  else
    @answer = "Well done. #{@player_throw} beats #{@computer_throw}"
    session[:win] += 1
    haml :result, :locals => { :session => session }
  end
end

post '/' do
  session[:win]=0
  session[:loose]=0
  session[:tie]=0
  redirect '/'
end

post '/clear' do
  session.clear
  redirect '/'
end