class ArticlesController < ApplicationController
  before_filter :get_articles, :only => [:index, :sort_by_temp]
  def index
    render :json => @articles
  end

  def sort_by_temp
    @sorted_articles = Rails.cache.fetch("n4g/articles/v1", :expires_in => 5.minute) do
      collect_articles
    end
  end

  private

  def get_articles
    require 'open-uri'

    url = "http://www.n4g.com/"
    doc = Nokogiri::HTML(open(url))

    @articles = Rails.cache.fetch("n4g/articles/v1", :expires_in => 5.minute) do 
      collect_articles
    end
  end

  def collect_articles
    @data = []
    doc = Nokogiri::HTML(open("http://www.n4g.com/"))
    doc.css(".sl-item").each do |item|
      element_link = item.css("h1 a")
      if (element_link.first.attr("href") =~ /\/ads\/(.*)/ ) 
      #do nothing
      else
        article_title = element_link.text

        article_source = item.css(".sl-source a").attr("href").text
        source = "http://www.n4g.com/#{article_source}"

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
