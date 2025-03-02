class AddImageToMusic < ActiveRecord::Migration[6.1]
  def change
    add_column :bands, :image_url, :string
  end
end
