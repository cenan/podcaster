require "kemal"
require "db"
require "sqlite3"

require "./podcaster/*"

SQLITE = DB.open("sqlite3:./db/podcaster.db")
at_exit { SQLITE.close }

SQLITE.exec "create table if not exists podcasts (id integer primary key autoincrement, rid string, name string)"

get "/" do
  files = [] of Hash(String, String)
  rs = SQLITE.query "select rid,name from podcasts"
  rs.each do
    h = {
      "id" => rs.read(String),
      "name" => rs.read(String)
    }
    files << h
  end
  rs.close
  render "src/views/index.ecr", "src/views/layouts/layout.ecr"
end

get "/listen/:id" do |env|
  file = "/audio/#{env.params.url["id"]}.mp3"
  render "src/views/listen.ecr", "src/views/layouts/layout.ecr"
end

post "/fetch_yt_video" do |env|
  url = env.params.body["url"].as(String)
  spawn {
    Podcaster::Downloader.new(url, SQLITE).run
  }
  env.redirect "/"
end

Kemal.run
