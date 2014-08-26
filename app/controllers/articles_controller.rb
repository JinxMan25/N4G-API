class ArticlesController < ApplicationController
  before_filter :get_articles, :only => [:index]
  def index
    @data = cell
    render :json => @data
  end

  private

  def get_articles
    url = "http://www.n4g.com/"
    doc = Nokogiri::HTML(open(url))

    cell = []
    
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

        temperature = item.css(".sl-item-temp").text

        tempCell = { :title => article_link, :link => source, :description => description, :temperature => temperature }
        cell << tempCell
      end
    end
  end

end
