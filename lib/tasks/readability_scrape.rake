namespace :readability_scrape do
  require 'open-uri'

  desc "TODO"
  task :fetch_article_body => :environment do
    hash = Rails.cache.fetch("n4g/articles/v1")
    url_array = hash.map { |hash| hash[:link] }
    url_array.each do |url|
      url.gsub!(/QUESTION/, "?url=http://")
      content = Rails.cache.fetch("http://readability.com/m#{url}", :expires_in => 2.day) do
        html = open("http://readability.com/m#{url}").read
      end
    end
  end

end
