require 'sinatra'
require 'erb'
require 'haml'

# Set the password of the cookie (optional)
set :session_secret, ENV["SESSION_KEY"] || 'too secret'

# before we process a route we'll set the response as plain text
# and set up an array of viable moves that a player (and the
# computer) can perform

#enable sessions to use cookies on client side
enable :sessions

# helper for escape HTMLcode
helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end
  
before do
  @defeat = { rock: :scissors, paper: :rock, scissors: :paper}
  @throws = @defeat.keys
end

get '/' do
  if session[:win] == nil # initialize cookie
    session[:win]=0
    session[:loose]=0
    session[:tie]=0
  end
  haml :index, :locals => { :session => session }
end

#process the throw with the user option
get '/throw/' do
  texto = params[:option].to_s.downcase # Read option and convert to downcase
  texto.gsub!(/\?*\=/, '')
  # the params hash stores querystring and form data
  @player_throw = texto.to_sym # Convert text to search in hash the option

  # Throw an exception with 3 seconds delay redirection back to the main page
  halt(403, "<meta http-equiv =\"refresh\", content =\"3; URL=/\"> <body> <h3>You must throw one of the following: '#{@throws.join(', ')}'</h3><h3>Redirecting to main page...</h3></body>") unless @throws.include? @player_throw

  @computer_throw = @throws.sample

  if @player_throw == @computer_throw 
    @answer = "There is a tie"
    session[:tie] += 1
    session[:color]="#0000FF"
    haml :result, :locals => { :session => session }
  elsif @player_throw == @defeat[@computer_throw]
    @answer = "Computer wins; #{@computer_throw} defeats #{@player_throw}"
    session[:loose] += 1
    session[:color]="#FF0000"
    haml :result, :locals => { :session => session }
  else
    @answer = "Well done. #{@player_throw} beats #{@computer_throw}"
    session[:win] += 1
    session[:color]="#008000"
    haml :result, :locals => { :session => session }
  end
end

post '/' do # Set the values of the cookie
  session[:win]=0
  session[:loose]=0
  session[:tie]=0
  redirect '/'
end

post '/clear' do # Reset the cookie and return to main page
  session.clear
  redirect '/'
end