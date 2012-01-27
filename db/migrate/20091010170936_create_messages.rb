class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.timestamps
      t.integer :user_to_id
      t.integer :user_from_id
      t.text :message
      t.string :subject
      t.integer :ticket_id
      t.boolean :read_message, :default => 0
      t.boolean :deleted_by_sender, :default => 0
      t.boolean :deleted_by_recipient, :default => 0
    end
  end

  def self.down
    drop_table :messages
  end
end
