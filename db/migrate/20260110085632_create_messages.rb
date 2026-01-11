class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.string :content
      t.references :rv_listing, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
    end
  end
end
