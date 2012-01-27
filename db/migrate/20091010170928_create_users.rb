class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.timestamps
      t.string :email
      t.string :password_hashed
      t.string :password_salt
      t.string :username, :min => 3, :max => 32
      t.string :ip
      t.boolean :admin
      t.boolean :banned
      t.text :default_bio
      t.text :default_interests
      t.timestamp :last_login_at
      t.integer :login_count, :default => 0
      t.boolean :admin
    end
  end

  def self.down
    drop_table :users
  end
end
