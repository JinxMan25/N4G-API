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

    links = []
    sources = []

    cells = []

    doc.css(".sl-item").each do |item|
      article_link = item.css("h1 a")
      if ( item.css("h1 a").first.attr("href") =~ /\/ads\/(.*)/ ) 

      else
        links << article_link.text
      end
    end
  end

end
