# frozen_string_literal: true

class CreateScoutRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :scout_runs do |t|
      t.references :user_profile, null: false, foreign_key: true
      t.text :goal, null: false
      t.string :status, null: false, default: 'draft'
      t.string :wallet_address
      t.string :somnia_request_id
      t.string :tx_hash
      t.string :callback_tx_hash
      t.string :result_hash

      t.timestamps
    end

    add_index :scout_runs, :status
    add_index :scout_runs, :wallet_address
    add_index :scout_runs, :somnia_request_id, unique: true
    add_index :scout_runs, :tx_hash
  end
end
