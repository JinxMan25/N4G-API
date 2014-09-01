class ArticlesController < ApplicationController
  before_filter :get_articles, :only => [:articles, :sort_by_temp]
  def articles
    byebug
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
    doc.css(".shsl-item a").each do |item|
      article_title = item.css(".shsl-item-title").text

      temperature = item.css('b[class^="shsl-temp"]').text

      article_link = 
    end
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

        temperature = item.css(".sl-item-temp").text.gsub!(/\D/, "")

        tempCell = { :title => article_title, :link => source, :description => description, :temperature => temperature }
        @data << tempCell
      end
    end
    @data
  end

end
