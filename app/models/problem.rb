class Problem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :number, :type => Integer
  field :score, :type => Integer

  belongs_to :contest
end
