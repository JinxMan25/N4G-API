class ArticlesController < ApplicationController
  before_filter :get_articles, :only => [:articles, :sort_by_temp]
  def articles

    @articles = { :articles => @all_articles }
    FetchArticles.perform_async
    #system "rake readability_scrape:fetch_article_body &"
    render :json => @articles 
  end

  def sort_by_temp
    @all_articles.sort_by!{ |hash| -hash[:temperature].to_i }
    @articles = { :articles => @all_articles }

    render :json => @articles
  end

  def next_page

    #pre-increment because n4g doesn't start at page 1
    page = params[:page_number].to_i + 1
    next_page_url = "http://n4g.com/channel/all/home/all/above50/medium/#{page}"

    doc = Nokogiri::HTML(open(next_page_url))

    @next_page_articles = Rails.cache.fetch("n4g/articles/#{page}", :expires_in => 15.minute ) do
      collect_articles(doc)
    end

    FetchArticles.perform_async

    @articles = { :articles => @next_page_articles }

    render :json => @articles
    
  end

  def search_article
    search_params = params[:search_query]
  end


  def filtered_stories

    #convert obj
    _filter = params[:filter].to_s
    if params[:page_number]
      page = params[:page_number].to_i 
    else
      page = 1
    end

    next_page_url = "http://n4g.com/channel/all/home/all/#{_filter}/medium/#{page}"

    doc = Nokogiri::HTML(open(next_page_url))

    @filtered_articles = Rails.cache.fetch("n4g/articles/#{_filter}/#{page}", :expires_in => 1.minute )  do
      collect_articles(doc)
    end

    @articles = { :articles => @filtered_articles }

    render :json => @articles
  end

  #TODO- use this for UIPageView
  def top_news
    doc = Nokogiri::HTML(open(URL))
    top_news_container = doc.css(".shsl-wrap")
    @top_articles = []
    top_news_container.css(".shsl-item").each do |item|
      article_title = item.css(".shsl-item-title").text.gsub(/nbsp/, "")
      temperature = item.css('b[class^="shsl-temp"]').text.gsub!(/\D/, "")

      comments = item.css(".shsl-item-comments").text

      img = item.css(".shsl-item-imagewrap-inner img").first.attr("src")
      
      tempCell = { :title => article_title, :temperature => temperature, :comments => comments, :image_url => img }

      @top_articles << tempCell
    end
    @articles = { :articles => @top_articles }
    render :json => @articles
  end

  def fetch_cached_page
    url = params[:url]
    url.gsub!(/HTTP/, "http://")
    url.gsub!(/QUESTION/, "?url=http://")

    #cache readability stripped body
    @web_content = Rails.cache.fetch("#{url}", :expires_in => 12.hours) do 
      truncate_url_webcontent(url)
    end

    doc = Nokogiri::HTML(@web_content)
    @content = doc.css("#rdb-article-content")
    @doc = @content.to_s

    render :html => @doc
  end

  def fetch_article_body
    require 'open-uri'
    url = params[:url]
    url.gsub!(/HTTP/, "http://")
    url.gsub!(/QUESTION/, "?url=http://")
    #test_url = "http://localhost:3000/articles/get/HTTPreadability.com/mQUESTIONn4g.com/news/clickout/1588316"
    doc = Nokogiri::HTML(open(url))
    
    @article_html_contents = doc.css("#rdb-article-content")
    
    render :html => @article_html_contents
  end

  private

  #read webpage to create Nokogiri obj
  def truncate_url_webcontent(url)
    require 'open-uri'

    html = open(url).read

  end

  def get_articles
    require 'open-uri'

    doc = Nokogiri::HTML(open(URL))

    @all_articles = Rails.cache.fetch("n4g/articles/v1", :expires_in => 5.minute) do 
      collect_articles(doc)
    end
  end

  def collect_articles(doc)

    @data = []
    doc.css(".sl-item").each do |item|
      element_link = item.css("h1 a")
      #skip ads
      if (element_link.first.attr("href") =~ /\/ads\/(.*)/ ) 
      #do nothing
      else
        article_title = element_link.text

        user = item.css(".sl-user a").text

        posted = item.css(".sl-item-description b").text

        #get article source
        
        article_source = item.css(".sl-source a").attr("href").text
        source = "#{URL}#{article_source}"
        source.gsub!(/http:\/\//, "QUESTION")

        #get actual article from clickout

        article_description = item.css(".sl-item-description")
        article_description.at('b').unlink
        description = article_description.text.split.join(" ")

        #get comment count

        comments = item.css(".sl-com2 a").text[/\d+/]
        if comments == nil
          comments = "0"
        end

        #get temperature
        
        temperature = item.css(".sl-item-temp").text.gsub!(/\D/, "")

        #get article thumbnail
        img = item.css(".sl-item-imagewrap img").first.attr("src")

        tempCell = { :title => article_title, :link => source, :description => description, :temperature => temperature, 
                     :comments => comments, :image_url => img, :posted => posted, :user => user}

        @data << tempCell
      end
    end
    #@data.each do |hash|
     # clickout = `curl --insecure #{hash[:link]}` 
      #clickout_body = Nokogiri::HTML(clickout)
      #clickout_link = clickout_body.css("h2 a").attr("href").text
      #hash.merge!(actual_link: clickout_link)
    #end
    @data
  end

end
