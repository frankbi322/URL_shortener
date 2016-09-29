class DropUniqunessConstraintFromShortenedUrl < ActiveRecord::Migration
  def change
    remove_index :shortened_urls, :user_id
    add_index :shortened_urls, :user_id
  end
end
