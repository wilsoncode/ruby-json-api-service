require 'active_record'
require 'activerecord-import'
require 'ipaddr'

ActiveRecord::Base.logger = Logger.new(STDERR)

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'jsonapi.sqlite3')

ActiveRecord::Schema.define do
    create_table :authors, if_not_exists: true do |t|
        t.string :username, index: { unique: true }
    end

    create_table :posts, if_not_exists: true do |t|
        t.integer :author_id
        t.string :title
        t.string :content
        t.string :ip
    end

    create_table :ratings, if_not_exists: true do |t|
      t.integer :post_id
      t.integer :rate
    end
end

class Author < ActiveRecord::Base
  has_many :posts, dependent: :destroy

  validates :username, presence: true, uniqueness: true
end

class Post < ActiveRecord::Base
  belongs_to :author
  has_many :ratings, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true
  validates :ip, presence: true
end

class Rating < ActiveRecord::Base
  belongs_to :post
  
  validates :rate, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5}
end

authors = 100.times.map do |author|
  Hash[username: "User No. #{author}"]
end

Author.import(authors.first.keys, authors.map(&:values), validate: false)

ips = 50.times.map do |ip|
  IPAddr.new(rand(2**32),Socket::AF_INET).to_s
end

posts = 200_000.times.map do |post|
  Hash[title: "Title #{post}", content: "Content #{post}", author_id: Array(0..99).sample, ip: ips.sample]
end

Post.import(posts.first.keys, posts.map(&:values), validate: false)
