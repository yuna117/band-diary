class AddUidToSetlists < ActiveRecord::Migration[6.1]
  def change
     add_column :setlists, :uid, :string
  end
end
