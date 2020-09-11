class CreateBrands < ActiveRecord::Migration[6.0]
  def change
    create_table :brands do |t|
      t.references :category, null: false, index: true

      t.string :name, null: false
      t.text :description
      t.text :why_removed
      t.string :logo

      t.boolean :bad, null: false, default: true

      t.timestamps
    end
  end
end
