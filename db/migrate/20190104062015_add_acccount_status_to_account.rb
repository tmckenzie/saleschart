class AddAcccountStatusToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :account_status, :integer, default: 0
  end
end
