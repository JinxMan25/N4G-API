class FetchArticles
  require 'open-uri'
  include Sidekiq::Worker

  def perform
    hash = Rails.cache.fetch("n4g/articles/v1")
    url_array = hash.map { |hash| hash[:link] }
    url_array.each do |url|
      url.gsub!(/QUESTION/, "?url=http://")
      content = Rails.cache.fetch("http://readability.com/m#{url}", :expires_in => 1.day) do
      html = open("http://readability.com/m#{url}").read
      end
    end
  end

end
