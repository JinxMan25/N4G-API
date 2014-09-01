class ArticlesController < ApplicationController
  before_filter :get_articles, :only => [:articles, :sort_by_temp]
  def articles
    render :json => @articles
  end

  def sort_by_temp
    @sorted_articles = Rails.cache.fetch("n4g/articles/v1", :expires_in => 5.minute) do
      collect_articles
    end
    @sorted_articles.sort_by!{ |hash| -hash[:temperature].to_i }
    render :json => @sorted_articles
  end

  def top_news
    doc = Nokogiri::HTML(open(URL))
    top_news_container = doc.css(".shsl-wrap")
    @articles = []
    top_news_container.css(".shsl-item").each do |item|
      article_title = item.css(".shsl-item-title").text.gsub(/nbsp/, "")
      temperature = item.css('b[class^="shsl-temp"]').text.gsub!(/\D/, "")

      comments = item.css(".shsl-item-comments").text

      img = item.css(".shsl-item-imagewrap-inner img").first.attr("src")
      
      tempCell = { :title => article_title, :temperature => temperature, :comments => comments, :image_url => img }

      @articles << tempCell
    end
    render :json => @articles
  end

  private

  def get_articles
    require 'open-uri'

    doc = Nokogiri::HTML(open(URL))

    @articles = Rails.cache.fetch("n4g/articles/v1", :expires_in => 5.minute) do 
      collect_articles
    end
  end

  def collect_articles
    @data = []
    doc = Nokogiri::HTML(open(URL))
    doc.css(".sl-item").each do |item|
      element_link = item.css("h1 a")
      if (element_link.first.attr("href") =~ /\/ads\/(.*)/ ) 
      #do nothing
      else
        article_title = element_link.text

        article_source = item.css(".sl-source a").attr("href").text
        source = "#{URL}#{article_source}"

        article_description = item.css(".sl-item-description")
        article_description.at('b').unlink
        description = article_description.text.split.join(" ")

        comments = item.css(".sl-com2 a").text[/\d+/]

        temperature = item.css(".sl-item-temp").text.gsub!(/\D/, "")

        img = item.css(".sl-item-imagewrap img").first.attr("src")

        tempCell = { :title => article_title, :link => source, :description => description, :temperature => temperature, :comments => comments, :image_url => img }
        @data << tempCell
      end
    end
    @data
  end

end
