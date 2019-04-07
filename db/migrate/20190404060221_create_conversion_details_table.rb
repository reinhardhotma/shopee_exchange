class CreateConversionDetailsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :conversion_details do |t|
      t.references :conversion, index: true
      t.date :date, null: false
      t.float :rate, null: false
    end
  end
end
