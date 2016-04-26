ActiveRecord::Schema.define do
  create_table :users do |t|
    t.timestamps
  end

  create_table :posts do |t|
    t.column :user_id, :integer
    t.column :text, :string

    t.timestamps
  end
end

