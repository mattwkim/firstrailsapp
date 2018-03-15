class CreateAdministrators < ActiveRecord::Migration[5.2]
  def change
    create_table :administrators do |t|
      t.string :name
    end
  end
end
