class Conversion < ActiveRecord::Base
  has_many :conversion_details
  validates :from, :uniqueness => {:scope => :to}
end