require 'date'

class ContestsController < ApplicationController
  # GET /contests
  # GET /contests.json
  def index
    @contests = Contest.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @contests }
    end
  end

  # GET /contests/1
  # GET /contests/1.json
  def show
    @contest = Contest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @contest }
    end
  end

  # GET /contests/new
  # GET /contests/new.json
  def new
    @contest = Contest.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @contest }
    end
  end

  # GET /contests/1/edit
  def edit
    @contest = Contest.find(params[:id])
  end

  def valid?(str)
    /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/ =~ str
  end

  def to_date(str)
    /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})$/ =~ str
    DateTime.new($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i)
  end

  # POST /contests
  # POST /contests.json
  def create
    @contest = Contest.new(params[:contest])

    begin_date = params[:begin_date]
    end_date = params[:end_date]

    @contest.errors[:begin_date] << 'is invalid.' unless valid? begin_date
    @contest.errors[:end_date] << 'is invalid.' unless valid? end_date

    @contest.begin_date = to_date(begin_date)
    @contest.end_date = to_date(end_date)

    problem_count = params.keys.select {|e| e.start_with? 'problem_id_' }.size
    1.upto(problem_count) do |i|
      id = params["problem_id_#{i}".intern]
      score = params["problem_score_#{i}".intern]
      @contest.errors[:problems] << 'id is invalid.' if id.nil?
      @contest.errors[:problems] << 'score is invalid.' if score.nil?
      problem = Problem.new({
        number: id.to_i,
        score: score.to_i,
        contest: @contest,
      })
      problem.save
      @contest.problems << problem
    end

    unless @contest.errors.empty?
      render action: 'new' and return
    end

    respond_to do |format|
      if @contest.save
        format.html { redirect_to @contest, notice: 'Contest was successfully created.' }
        format.json { render json: @contest, status: :created, location: @contest }
      else
        format.html { render action: "new" }
        format.json { render json: @contest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /contests/1
  # PUT /contests/1.json
  def update
    @contest = Contest.find(params[:id])

    begin_date = params[:begin_date]
    end_date = params[:end_date]

    @contest.errors[:begin_date] << 'is invalid.' unless valid? begin_date
    @contest.errors[:end_date] << 'is invalid.' unless valid? end_date

    @contest.begin_date = to_date(begin_date)
    @contest.end_date = to_date(end_date)

    respond_to do |format|
      if @contest.update_attributes(params[:contest])
        format.html { redirect_to @contest, notice: 'Contest was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @contest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contests/1
  # DELETE /contests/1.json
  def destroy
    @contest = Contest.find(params[:id])
    @contest.destroy

    respond_to do |format|
      format.html { redirect_to contests_url }
      format.json { head :no_content }
    end
  end
end
