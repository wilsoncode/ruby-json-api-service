require 'active_record'
require 'json'
require 'rack'
require 'rack/handler/puma'
require 'sqlite3'

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

app = -> environment {
  request = Rack::Request.new(environment)
  response = Rack::Response.new
  response.content_type = 'application/json'

  if request.post? && request.path == '/post/create'
    @author = Author.find_or_create_by!(username: request.params['username'])
    @post = @author.posts.new(title: request.params['title'], content: request.params['content'], ip: request.ip)
    if @post.invalid?
      response.status = 422
      response.write({:message => @post.errors.full_messages.inspect}.to_json)
    else
      @post.save()
      response.write(@post.to_json)
    end
  elsif request.post? && request.path == '/post/rate'
    begin
      @post = Post.find(request.params['post_id'])
      @rating = @post.ratings.new(rate: request.params['rate'])
      if @rating.invalid?
        response.status = 422
        response.write({:message => @rating.errors.full_messages.inspect}.to_json)
      else
        @rating.save()
        response.write({:average => @post.ratings.average(:rate), :total_count => @post.ratings.length()}.to_json)
      end
    rescue ActiveRecord::RecordNotFound => exception
      response.status = 422
      response.write({:message => exception}.to_json)
    end
  elsif request.get? && request.path == '/posts/top'
    @limit = request.params['limit']
    @posts = Post.select('posts.id, posts.title, posts.content, avg(ratings.rate) as average_rating')
      .joins(:ratings)
      .group(:id)
      .order(average_rating: :desc)
      .limit(@limit)
    response.write(@posts.to_json)
  else
    response.write({:message => 'App is running!'}.to_json)
  end

  response.finish
}

Rack::Handler::Puma.run(app, :Port => 1337, :Verbose => true)
