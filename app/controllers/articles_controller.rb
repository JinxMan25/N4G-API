class ArticlesController < ApplicationController
  before_filter :get_articles, :only => [:index]
  def index

  end

  private

  def get_articles
  
  end
end
