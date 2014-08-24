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

        article_source = item.css(".sl-source a").attr("href").text
        source = "http://www.n4g.com/#{article_source}"

        article_description = item.css(".sl-item-description")
        article_description.at('b').unlink
        description = article_description.text.split.join(" ")
      end
    end
  end

end
