class AjaxController < ApplicationController

  # GET /users
  def valid_aoj_id
    redirect_to '/404.html' and return unless request.xhr?
    user = AOJ::User.new(params[:aoj_id])
    res = if user.valid? then 'ok' else 'ng' end
    render :json => {status: res}
  end

end
