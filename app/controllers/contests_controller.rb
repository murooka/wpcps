require 'date'

class ContestsController < AuthController
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

    @participated = @contest.participants.include? @current_user

    current = DateTime.now
    @state = @contest.begin_date > current ? Contest::STATE_BEFORE
                                           : @contest.end_date > current ? Contest::STATE_CURRENT
                                                                         : Contest::STATE_AFTER

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @contest }
    end
  end

  # GET /contests/new
  # GET /contests/new.json
  def new
    @contest = Contest.new
    @problem_count = 4

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @contest }
    end
  end

  # GET /contests/1/edit
  def edit
    @contest = Contest.find(params[:id])
    @problem_count = @contest.problems.size + 1
  end


  # POST /contests
  # POST /contests.json
  def create
    @contest = Contest.new(params[:contest])

    @contest.begin_date_str = params[:begin_date]
    @contest.end_date_str = params[:end_date]

    problems = []
    for i,p in params[:problems]
      number = p[:number]
      score = p[:score]

      next if number.blank? && score.blank?
      @contest.errors[:problem] << "#{i}'s number is invalid." and next if number.blank?
      @contest.errors[:problem] << "#{i}'s score is invalid." and next if score.blank?

      aoj_problem = AOJ::Problem.new(number)
      @contest.errors[:problem] << "#{i} is invalid." and next unless aoj_problem.valid?
      problem = Problem.new({
        number: number.to_i,
        name: aoj_problem.name,
        score: score.to_i,
        contest: @contest,
      })
      problems << problem
    end
    @contest.problems = problems

    @problem_count = 4

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

  # GET /contests/1/result
  def result
    @contest = Contest.find(params[:id])

    @result_table = @contest.participants.map do |user|
      total_score = 0
      total_time = 0
      status = @contest.problems.map do |prob|
        submission = user.submissions.where(problem_id: prob.id).first
        unless submission.nil?
          t = (submission.date.to_aoj_time - @contest.begin_date.to_aoj_time) / 1000
          time = sprintf('%02d:%02d', t/60, t%60)
          score = prob.score
          total_score += score
          total_time = t if t>total_time
          next {score: score, time: time}
        end

        record = AOJ::Record.new(user.name, prob.number_str, @contest.begin_date.to_aoj_time, @contest.end_date.to_aoj_time)
        if record.valid?
          t = (record.solved.date.to_i - @contest.begin_date.to_aoj_time) / 1000
          time = sprintf('%02d:%02d', t/60, t%60)
          score = prob.score
          total_time = t if t>total_time

          user.solve(prob, DateTime.from_aoj_time(record.solved.date.to_i))
        else
          score = 0
          time = '--:--'
        end
        total_score += score
        {score: score, time: time}
      end
      {user: user, status: status, total: {score: total_score, time: sprintf('%02d:%02d', total_time/60, total_time%60)}}
    end

    # sample
    # @result_table = [
    #   {user: @current_user, status: [{score: 15, time: '07:32'}, {score: 33, time: '11:56'}] , total: {score: 48, time: '11:56'} },
    # ]

    respond_to do |format|
      format.html
    end
  end

  # POST /contests/1/participate
  def participate
    @contest = Contest.find(params[:id])
    @contest.participants << @current_user
    @contest.save
    
    redirect_to @contest, notice: 'Succesfully participated'
  end
end
