class ArticlesController < ApplicationController
  before_filter :get_articles, :only => [:index]
  def index
    @data = { :links => links }
    render :json => @data

  end

  private

  def get_articles
    url = "http://www.n4g.com/"
    doc = Nokogiri::HTML(open(url))

    doc.css(".sl-item").each do |item|
      element_link = item.css("h1 a")
      if (element_link.first.attr("href") =~ /\/ads\/(.*)/ ) 
      #do nothing
      else
        element_title = article_link.text
        links << element_link.text
      end
    end

    doc.css(".sl-source a"). each do |source|
      sources << source['href']
    end
  end

end
