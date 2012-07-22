class Contest
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, :type => String
  field :begin_date, :type => DateTime
  field :end_date, :type => DateTime

  has_and_belongs_to_many :participants, class_name: "User"
  has_many :problems, autosave: true

  def begin_date_str=(str)
    self.errors[:begin_date] << 'is empty' and return if str.blank?

    date = to_date_or_nil(str)
    if date.nil?
      self.errors[:begin_date] << 'is invalid.'
    else
      self.begin_date = date
    end
  end

  def end_date_str=(str)
    self.errors[:end_date] << 'is empty' and return if str.blank?

    date = to_date_or_nil(str)
    if date.nil?
      self.errors[:end_date] << 'is invalid.'
    else
      self.end_date = date
    end
  end

  def begin_date_str
    self.begin_date.strftime('%Y-%m-%d %H:%M')
  end

  def end_date_str
    self.end_date.strftime('%Y-%m-%d %H:%M')
  end

  DATETIME_REGEX = /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})$/

  private
  def to_date_or_nil(str)
    if DATETIME_REGEX =~ str
      DateTime.new($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i)
    else
      nil
    end
  end


end
