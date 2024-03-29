require 'date'
require 'time'

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :current_user

  TOKEN_CHAR_ARRAY = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
  def generate_random_token(length=10)
    token = ''
    length.times do
      token += TOKEN_CHAR_ARRAY[rand(TOKEN_CHAR_ARRAY.length)]
    end
    token
  end


  def login_user(user)
    session[:user_name] = user.name
  end

  def logout_user
    session[:user_name] = nil
  end

  def current_user
    @current_user = User.where(:name=>session[:user_name]).first
    @authorized = @current_user.nil? ? false : true
    @current_user
  end


  def login_filter
    if !@authorized
      redirect_to controller: 'users', action: 'login'
    end
  end

  def admin_filter
    unless @current_user && @current_user.is_admin
      redirect_to controller: 'top', action: 'index'
    end
  end

end

class DateTime
  def self.from_aoj_time(time)
    DateTime.parse(Time.at(time/1000).to_s)
  end

  def to_aoj_time
    Time.parse(self.to_s).to_i * 1000
  end

end
