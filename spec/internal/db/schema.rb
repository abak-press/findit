ActiveRecord::Schema.define do
  create_table :users, &:timestamps

  create_table :posts do |t|
    t.column :user_id, :integer
    t.column :text, :string

    t.timestamps
  end
end

