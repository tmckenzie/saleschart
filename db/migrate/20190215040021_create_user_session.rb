class CreateUserSession < ActiveRecord::Migration
  def change
    create_table :user_sessions do |t|
      t.integer  :user_id
      t.string   :session_token
      t.datetime :expire_at
      t.timestamps
    end
    add_index(:user_sessions, [:user_id], unique: true, name: 'index_user_session_uq')
  end
end
