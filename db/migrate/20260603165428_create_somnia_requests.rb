# frozen_string_literal: true

class CreateSomniaRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :somnia_requests do |t|
      t.references :scout_run, null: false, foreign_key: true
      t.string :agent_id, null: false
      t.string :request_id
      t.string :status, null: false, default: 'draft'
      t.string :request_tx_hash
      t.string :callback_tx_hash
      t.jsonb :payload, null: false, default: {}
      t.jsonb :response, null: false, default: {}

      t.timestamps
    end

    add_index :somnia_requests, :agent_id
    add_index :somnia_requests, :request_id, unique: true
    add_index :somnia_requests, :status
    add_index :somnia_requests, :request_tx_hash
    add_index :somnia_requests, :callback_tx_hash
  end
end
