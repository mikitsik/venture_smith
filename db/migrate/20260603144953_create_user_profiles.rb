# frozen_string_literal: true

class CreateUserProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :user_profiles do |t|
      t.string :name
      t.text :background
      t.integer :available_days
      t.string :github_url
      t.string :linkedin_url

      t.timestamps
    end
  end
end
