require 'byebug'
class ShortenedUrl < ActiveRecord::Base
  validates :short_url, presence: true, uniqueness: true
  validates :long_url, presence: true
  validates :user_id, presence: true
  validate :valid_length
  validate :spam_blocker
  validate :pay_to_win

  def valid_length
    # debugger
    if self.long_url.nil? || self.long_url.length > 1024
      self.errors[:long_url] << "must a string under 1024 characters."
    end
  end

  def pay_to_win
    unless self.submitter.premium ||
           self.submitter.submitted_urls.count < 5
      self.errors[:premium] << "required to maintain more than 5 URLS."
    end
  end

  def spam_blocker
    if (self.class.where(user_id: user_id).
        where('created_at > ?', 1.minutes.ago).
        count >= 5)
      self.errors[:user_id] << "is a dirty spammer."
    end
  end

  def self.prune(n)
    ShortenedUrl.select('shortened_urls.id').joins(:visits).
    group('shortened_urls.id').
    having('max(visits.created_at) < ?', n.minutes.ago).
    each do |url|
      url.visits.map(&:destroy)
      url.destroy
    end
  end

  def self.create_for_user_and_long_url!(user,long_url)
    raise ArgumentError.new("user_id can't be null") if user.nil?
    raise ArgumentError.new("long_url can't be null") if long_url.nil?
    self.create!(user_id: user, long_url: long_url,
                 short_url: self.random_code)

  end

  def self.random_code
    code = SecureRandom::urlsafe_base64(12)
    while self.exists?(short_url:code)
      code = SecureRandom::urlsafe_base64(12)
    end
    code
  end

  def num_clicks
    visits.count
  end

  def num_uniques
    visitors.count
  end

  def num_recent_uniques(n)
    visitors.where("visits.created_at > ?",n.minutes.ago).distinct.count
  end

  belongs_to(
    :submitter,
    class_name: :User,
    primary_key: :id,
    foreign_key: :user_id
  )

  has_many(
    :visits,
    class_name: :Visit,
    primary_key: :id,
    foreign_key: :shortened_url_id
  )

  has_many(
    :visitors,
    Proc.new {distinct},
    through: :visits,
    source: :visitor
  )

  has_many(
    :taggings,
    class_name: :Tagging,
    primary_key: :id,
    foreign_key: :shortened_url_id
  )

  has_many(
    :topics,
    through: :taggings,
    source: :topic
  )
end
