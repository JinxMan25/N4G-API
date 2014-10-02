namespace :readability_scrape do
  require 'open-uri'

  desc "Fetching articles..."
  task :fetch_article_body => :environment do
    hash = Rails.cache.fetch("n4g/articles/v1")
    url_array = hash.map { |hash| hash[:link] }
    url_array.each do |url|
      url.gsub!(/QUESTION/, "?url=http://")
      content = Rails.cache.fetch("http://readability.com/m#{url}", :expires_in => 1.day) do
        html = open("http://readability.com/m#{url}").read
      end
    end
  end

  task :fetch_5_page_articles_body do
    page = 2
    while page <= 5 
      hash = Rails.cache.read("n4g/articles/#{page}")
      url_array = hash.map { |hash| hash[:link] }
      url_array.each do |url|
        url.gsub!(/QUESTION/, "?url=http://")
        content = Rails.cache.fetch("http://readability.com/m#{url}", :expires_in => 1.day) do
          html = open("http://readability.com/m#{url}").read
        end
      end
      page +=1
    end
  end

end
