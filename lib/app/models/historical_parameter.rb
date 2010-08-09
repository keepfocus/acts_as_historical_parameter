class HistoricalParameter < ActiveRecord::Base
  belongs_to :parameterized, :polymorphic => true
end
