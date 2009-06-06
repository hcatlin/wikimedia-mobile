class Articles < Application
  provides :wml
  provides :html
  provides :json
  override! :content_type

  def home
    cache_block do
      @main_page = Wikipedia.main_page(request.language_code)
    
      format_display_with_data do
        {:title => "::Home", :html => render(:layout => false)}
      end
    end
  end
  
  def random
    @article = Article.random(current_server)
    redirect(@article.path)
  end
  
  def show
    if current_name == ""
      redirect "/wiki/::Home"
    elsif current_name[0..1] == "::"
      redirect "/wiki/#{current_name}"
    else
      cache_block do
        # Perform a normal search
        @article = Article.new(current_server, current_name)
        @article.fetch!
        format_display_with_data do
          @article.to_hash(request.device)
        end
      end
    end
  end
  
  def file
    cache_block do
      @article = current_server.file(params[:file])
      format_display_with_data do
        @article.to_hash(request.device)
      end
    end
  end
  
 private 
 
  def format_display_with_data(&block)
    case content_type
    when :json
      json = JSON.dump(block.call)
      if params[:callback]
        json = "#{params[:callback]}(#{json})"
      end
      render json, :format => :json
    else
      render :layout => request.device.with_layout
    end
  end
 
  def content_type
    if params[:format]
      params[:format].to_sym
    else
      :html
    end
  end
  
  def cache_block(&block)
    time_to "cache block" do
      key = cache_key
      cached = Cache[key]
      if cached
        Merb.logger.debug("CACHE HIT")
        return cached 
      end
    
      html = block.call
      
      time_to "store in cache" do
        Cache.store(key, html, :expires_in => 60 * 60 * 3)
      end

      Merb.logger.debug("CACHE MISS")
      html
    end
  end
  
  def current_name
    @name ||= (params[:search] || params[:title] || params[:file] || "").gsub("_", " ")
  end
  
  def cache_key
    "#{current_name}##{request.language_code}##{request.device.format_name}##{content_type}##{params[:callback]}}".gsub(" ", "-")
  end
end
