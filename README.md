# JSON API service using Ruby

## Running the app
1. Install dependencies.
  ```sh
  $ bundle install
  ```
2. Run the `lib/seeds.rb` to populate the database.
   ```sh
   $ ruby lib/seeds.rb
   ```
3. Start the server
  ```sh
  $ ruby lib/tcp_server.rb
```

## Question 1
- Setup rack and puma to run the server and listen to incoming connection.
- Use active record to manage models and db query.
  - SQLite setup as storage for the app.
  - Upon server start, tables will be created if doesn't yet exists.
- Handle incoming request for `POST /post/create` that accept `title`, `content`, and `username`.
  - Lookup existing `username` else create.
  - Save post associated with author.

## Question 2
- Handle incoming request for `POST /post/rate` that accept `post_id` and `rate` of 1-5.
- Returns average rating and total submitted ratings for the specific post.

## Question 3
- Handle incoming request for `GET /posts/top` that takes `limit` as query string parameter.
- Returns list of post sorted by top average rating.

## Question 4
- Handle incoming request for `GET /ips`.
- Returns list of ips with its associated users.
