class AjaxController < ApplicationController

  # GET /ajax/valid_aoj_id
  def valid_aoj_id
    redirect_to '/404.html' and return unless request.xhr?
    user = AOJ::User.new(params[:aoj_id])
    res = if user.valid? then 'ok' else 'ng' end
    render :json => {status: res}
  end

  # GET /ajax/problem_name
  def problem_name
    redirect_to '/404.html' and return unless request.xhr?
    problem = AOJ::Problem.new(params[:problem_id])
    res = if problem.valid? then problem.name else 'problem does not exist' end
    render :json => {name: res}
  end

end
