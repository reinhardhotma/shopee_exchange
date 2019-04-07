class ConversionDetail < ActiveRecord::Base
  belongs_to :conversion
  validates :date, :uniqueness => {:scope => :conversion_id}
end