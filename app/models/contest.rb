class Contest
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, :type => String
  field :begin_date, :type => DateTime
  field :end_date, :type => DateTime

  has_many :participants, class_name: "User"
  has_many :problems
end
