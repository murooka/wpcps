class Submission

  include Mongoid::Document
  include Mongoid::Timestamps

  field :date, type: DateTime

  belongs_to :user
  belongs_to :problem

end
