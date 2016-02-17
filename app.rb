class App < Sinatra::Base

  helpers WillPaginate::Sinatra, WillPaginate::Sinatra::Helpers

  get '/' do
    @auth = authorized?
    @images = Image.all.paginate(:page => params[:page], :per_page => 3)
    erb :index
  end

  get "/images/:id" do
    @image = Image[params[:id]]
    erb :show
  end

  get "/auth" do
    protected!
    redirect "/"
  end

  post "/images" do
    protected!
    binding.pry
    params[:image].each do |image|
      image["title"] = params[:image].last["title"]
      @image = Image.new image
      @image.save
    end
    redirect "/"
  end

  helpers do
    def protected!
      return if authorized?
      headers["WWW-Authenticate"] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'admin']
    end
  end
end
