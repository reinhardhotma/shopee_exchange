class CreateConversionsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :conversions do |t|
      t.string :from, null: false
      t.string :to, null: false
    end
  end
end
