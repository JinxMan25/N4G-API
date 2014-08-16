class ArticlesController < ApplicationController
  before_filter :get_articles, :only => [:index]
  def index

  end

  private

  def get_articles

  url = "http://www.n4g.com/"
  doc = Nokogiri::HTML(open(url))
  links = []
  sources = []

  doc.css(".sl-item-textwrap h1 a").each do |item|
    if ( item['href'] =~ /\/ads\/(.*)/ ) 

    else
      links << item.text
    end
  puts item.text
  end

  end
end
