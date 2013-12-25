require "sinatra"
require "sinatra/basic_auth"
require_relative 'member'

set :public_dir, Proc.new { File.join(root, "_site") }
set :views, Proc.new { File.join(File.dirname(__FILE__), "views") }

# Specify your authorization logic
authorize do |username, password|
  Member.authorize(username, password)
end

# Set protected routes
protect do
  get "/members/*" do
    serve
  end
end

before do
  @_max_age ||= ENV['CACHE_MAX_AGE'] || 36000
  response.headers['Cache-Control'] = "public, max-age=#{@_max_age}"
end

# remove all trailing slashes
get %r{(/.*)\/$} do
  redirect "#{params[:captures].first}"
end

# serve the jekyll site from the _site folder
get '/*' do
  serve
end

def serve
  file_name = "_site#{request.path_info}/index.html".gsub(%r{\/+},'/')
  if File.exists?(file_name)
    File.read(file_name)
  else
    raise Sinatra::NotFound
  end
end
