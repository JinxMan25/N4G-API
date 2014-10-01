namespace :readability_scrape do

  desc "TODO"
  task :fetch_article_body => :environment do
    hash = Rails.cache.fetch("n4g/articles/v1")
    url_array = hash.map { |hash| hash[:link] }
    url_array.each do |url|
      Rails.cache.fetch("#{url}") do
        doc = Nokogiri::HTML(open(url))

        web_content = doc.css("#rdb-article-content")

        web_content
      end
    end
  end

end
