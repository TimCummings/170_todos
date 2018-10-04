require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

configure do
  enable :sessions
  set :session_secret, 'secret'
end

# return an error message if the name is invalid; return nil if name is valid
def error_for_list_name(name)
  if !(1..100).cover? name.size
    'The list name must be between 1 and 100 characters.'
  elsif @lists.any? { |list| list[:name] == name }
    'List name must be unique.'
  end
end

before do
  session['lists'] ||= []
  @lists = session['lists']
end

get '/' do
  redirect '/lists'
end

# view all lists
get '/lists' do
  @lists = session['lists']
  erb :lists
end

# render the new list form
get '/lists/new' do
  erb :new_list
end

# create a new list
post '/lists' do
  list_name = params['list_name'].strip

  error = error_for_list_name(list_name)
  if error
    session['error'] = error
    erb :new_list
  else
    session['lists'] << { name: list_name, todos: [] }
    session['success'] = 'The list has been created.'
    redirect '/lists'
  end
end

# view a specific list by id
get '/lists/:list_id' do
  list_id = params['list_id'].to_i
  @list = @lists[list_id]
  erb :list
end
