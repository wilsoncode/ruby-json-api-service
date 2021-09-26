# JSON API service using Ruby

## Running the app
1. Install dependencies.
  ```sh
  $ bundle install
  ```
2. Start the server
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
