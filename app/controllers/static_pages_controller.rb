class StaticPagesController < ApplicationController

  def home
  	@home_page = true
  end

  def not_allowed_access
  end

  def help
  end

  def about
  end

  def faq
  end

  def manual
  end

  def privacy
  end

  def api
  end

  def security
  end

  def terms
  end

end
