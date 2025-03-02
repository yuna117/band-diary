class CreateSetlists < ActiveRecord::Migration[6.1]
  def change
    create_table :setlists do |t|
      t.date :date
      t.integer :musics, array: true, default: []
    end
  end
end
