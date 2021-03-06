ActiveRecord::Schema.define(:version => 0) do
  create_table :dummy_installations, :force => true do |t|
    t.string :name
  end
  create_table :historical_parameters, :force => true do |t|
    t.datetime :valid_from
    t.integer :ident
    t.float :value
    t.references :parameterized, :polymorphic => true

    t.timestamps
  end
end
