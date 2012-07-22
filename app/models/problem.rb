class Problem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :number, :type => Integer
  field :score, :type => Integer
  field :name, :type => String


  has_many :submissions
  belongs_to :contest

  validates_numericality_of :number, greater_than_or_equal_to: 0
  validates_numericality_of :score, greater_than: 0, less_than: 10000

  def number_str
    sprintf '%04d', self.number
  end

end
