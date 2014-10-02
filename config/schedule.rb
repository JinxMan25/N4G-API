every 5.minutes do
  rake "readability_scrape:fetch_article_body"
end

every 1.hours do
  rake "readability_scrape:fetch_5_page_articles_body" 
end
