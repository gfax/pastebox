require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-migrations'
require 'htmlentities'
require 'slim'

DataMapper.setup(:default, "sqlite3:///" + File.dirname(__FILE__) +  "/paste.sqlite3")
 
class Snippet
  include DataMapper::Resource
  property :id,         Serial # primary serial key
  property :title,      String, :required => true, :length => 64 
  property :body,       Text,   :required => true
  property :lang,       String, :length => 12
  property :created_at, DateTime
  property :updated_at, DateTime
  # validates_present :body
  # validates_length :body, :minimum => 1
end

DataMapper.auto_upgrade!


class Paste < Sinatra::Base

  set :layout_engine, :slim

  # new
  get '/' do
    slim :edit
  end

  # create/update
  post '/' do
    #title = HTMLEntities.new.encode params[:snippet_title]
    #body = HTMLEntities.new.encode params[:snippet_body]
    title_max = 64
    if params[:snippet_title].length > title_max
      @error = "Title must be #{title_max} characters or less."
    end
    if @error.nil?
      if params[:id].nil? || params[:id].empty?
        @snippet = Snippet.new(:title => params[:snippet_title],
                               :body => params[:snippet_body])
        result = @snippet.save
      else 
        @snippet = Snippet.get(params[:id])
        result = @snippet.update(:title => params[:snippet_title],
                                 :body => params[:snippet_body])
      end
    end
    if result
      redirect "/#{@snippet.id}"
    else
      slim :edit
    end
  end

  # show
  get '/:id' do
    @snippet = Snippet.get(params[:id])
    if @snippet
      slim :show
    else
      @error = "Sorry. That snippet does not exist."
      slim :edit 
    end
  end

  # show/save with specific language
  post '/:id' do
    @snippet = Snippet.get(params[:id])
    @lang = params[:lang]
    save = params[:save] == 'true' ? true : false
    if @snippet
      result = @snippet.update(:lang => params[:lang]) if save
      if !result && save
        @error = "Sorry. Could not save the snippet language."
      elsif save 
        @success = "Success! The snippet was saved."
      end
      slim :show
    else
      @error = "Sorry. That snippet does not exist."
      slim :edit 
    end
  end

  # show raw
  get '/raw/:id' do 
    @snippet = Snippet.get(params[:id])
    if @snippet
      slim :show_raw, :layout => false
    else
      @error = "Sorry. That snippet does not exist."
      slim :edit
    end
  end

  # edit
  get '/edit/:id' do
    @snippet = Snippet.get(params[:id])
    if !@snippet
      @error = "Sorry. That snippet does not exist."
    end
    slim :edit
  end

  # delete
  get '/delete/:id' do
    @snippet = Snippet.get(params[:id])
    if @snippet
      result = @snippet.destroy
      if result
        @success = "Success! Snippet #{@snippet.id} has been deleted."
        @snippet = nil
      else
        @error = "Sorry.  The snippet could not be deleted." 
      end
    else
      @error = "Sorry. That snippet does not exist."
    end
    slim :edit
  end

end
