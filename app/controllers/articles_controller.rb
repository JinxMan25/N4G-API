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
      if ( item['href'] =~ /\/ads\/(.*)/ ) 

      else
        links << item.text
      end
    end
  end

end
