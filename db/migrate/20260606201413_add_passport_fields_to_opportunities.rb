# frozen_string_literal: true

class AddPassportFieldsToOpportunities < ActiveRecord::Migration[8.1]
  def change
    change_table :opportunities, bulk: true do |t|
      t.string :passport_id
      t.string :passport_tx_hash
      t.string :passport_metadata_hash
      t.string :passport_metadata_uri
    end

    add_index :opportunities, :passport_id, unique: true
    add_index :opportunities, :passport_tx_hash
    add_index :opportunities, :passport_metadata_hash
  end
end
