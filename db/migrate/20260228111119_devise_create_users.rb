# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Invitable
      t.string   :invitation_token
      t.datetime :invitation_created_at
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
      t.integer  :invitation_limit
      t.references :invited_by, polymorphic: true
      t.integer  :invitations_count, default: 0

      ## Profile fields
      t.string  :name, null: false
      t.text    :bio
      t.string  :city
      t.string  :country
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.boolean :show_on_map, default: false, null: false

      ## Role
      t.integer :role, default: 0, null: false

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :invitation_token,     unique: true
    add_index :users, :invitations_count
    add_index :users, [:latitude, :longitude]
  end
end
