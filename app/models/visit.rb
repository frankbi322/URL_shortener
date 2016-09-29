class Visit < ActiveRecord::Base

  validates :shortened_url_id, presence: true
  validates :user_id, presence: true

  belongs_to(
    :visitor,
    class_name: :User,
    primary_key: :id,
    foreign_key: :user_id
  )

  belongs_to(
    :short_url,
    class_name: :ShortenedUrl,
    primary_key: :id,
    foreign_key: :shortened_url_id

  )


end
