class UsersController < ApplicationController
  before_filter :login_filter, :except=>['login', 'register', 'authorize', 'create']

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])
    raw_password = params[:password]
    salt = generate_random_token(10)
    encrypted_password = User.encrypt_password(raw_password, salt)

    @user.salt = salt
    @user.encrypted_password = encrypted_password

    # TODO
    # validationはmodelに書く
    aoj_id = params[:user][:aoj_id]
    aoj_user = AOJ::User.new(aoj_id)
    if not aoj_user.valid?
      @user.errors[:aoj_id] << 'is not valid account'
      render action: 'new' and return
    end

    respond_to do |format|
      if @user.save
        login_user(@user)
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  # GET /users/login
  def login
    redirect_to root and return if @authorized
  end

  # POST /users/login
  def authorize
    name = params[:name]
    raw_password = params[:password]

    user = User.authenticate(name, raw_password)
    redirect_to :back, alert: 'invalid name or password' and return if user.nil?

    login_user(user)
    redirect_to :root, notice: 'Login successfully'
  end

  # GET /users/register
  def register
    @user = User.new

    respond_to do |format|
      format.html
    end
  end

  # POST /users/logout
  def logout
    logout_user
    redirect_to :root, notice: 'Logout successfully'
  end

end
