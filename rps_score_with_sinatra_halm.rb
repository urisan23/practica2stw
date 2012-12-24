require 'sinatra'
require 'haml'

# before we process a route we'll set the response as plain text
# and set up an array of viable moves that a player (and the
# computer) can perform.
before do
  @defeat = { rock: :scissors, paper: :rock, scissors: :paper}
  @throws = @defeat.keys
end

get '/' do
    haml :index
end

get '/throw/' do
  # the params hash stores querystring and form data
	@option = params['option'.to_sym].downcase
	@player_throw = @option.to_sym

  halt(403, "Debes seleccionar una de las siguientes opciones: '#{@throws.join(', ')}'") unless @throws.include? @player_throw

  @computer_throw = @throws.sample

  if @player_throw == @computer_throw 
    @answer = "Se ha producido un empate."
    #erb :index
  elsif @player_throw == @defeat[@computer_throw]
    @answer = "El ordenador gana; #{@computer_throw} derrota a #{@player_throw}."
    #erb :index
  else
    @answer = "Muy bien. #{@player_throw} vence a #{@computer_throw}."
    #erb :index
  end
  haml :resultado
end
