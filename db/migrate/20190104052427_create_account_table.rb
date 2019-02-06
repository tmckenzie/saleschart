class CreateAccountTable < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.references :accountable, :polymorphic => true
      t.timestamps
    end
  end
end
