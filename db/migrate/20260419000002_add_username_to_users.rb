class AddUsernameToUsers < ActiveRecord::Migration[7.1]
  class MigrationUser < ApplicationRecord
    self.table_name = "users"
  end

  def up
    add_column :users, :username, :string

    MigrationUser.reset_column_information

    MigrationUser.find_each do |user|
      base = user.email.to_s.split("@").first.downcase.gsub(/[^a-z0-9_-]/, "_")
      base = "user" if base.blank?
      base = base.first(20)
      base = base.ljust(3, "0") if base.length < 3

      candidate = base
      suffix = 2

      while MigrationUser.where.not(id: user.id).where("LOWER(username) = ?", candidate.downcase).exists?
        suffix_text = "_#{suffix}"
        candidate = "#{base.first(20 - suffix_text.length)}#{suffix_text}"
        suffix += 1
      end

      user.update_columns(username: candidate)
    end

    change_column_null :users, :username, false
    add_index :users, 'LOWER(username)', name: 'index_users_on_lower_username', unique: true
  end

  def down
    remove_index :users, name: 'index_users_on_lower_username'
    remove_column :users, :username
  end
end
