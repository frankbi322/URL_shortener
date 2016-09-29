class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.integer :tag_topic_id, null: false
      t.integer :shortened_url_id, null: false
      t.timestamps
    end

    add_index :taggings, :tag_topic_id
    add_index :taggings, :shortened_url_id

    create_table :tag_topics do |t|
      t.string :topic, null: false
      t.timestamps
    end
  end
end
