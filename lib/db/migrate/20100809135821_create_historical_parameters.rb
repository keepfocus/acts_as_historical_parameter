class CreateHistoricalParameters < ActiveRecord::Migration
  def self.up
    create_table :historical_parameters, :force => true do |t|
      t.datetime :valid_from
      t.integer :ident
      t.float :value
      t.references :parameterized, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :historical_parameters
  end
end
