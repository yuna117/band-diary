class CreateBand < ActiveRecord::Migration[6.1]
  def change
    create_table :bands do |t|
      t.string :name
      t.string :uid
      t.string :img_url
      t.string :password_digest
    end
    
    create_table :musics do |t|
      t.string :name
      t.string :artist
      t.text :lyrics
      t.string :url
      t.text :norikata
      t.integer :band_id
    end
    
  end
end
