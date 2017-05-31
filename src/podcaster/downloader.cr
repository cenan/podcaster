require "db"

module Podcaster
  class Downloader
    def initialize(url : String, _db : DB::Database)
      @url = url
      @db = _db
    end

    def run
      command = "youtube-dl --extract-audio --audio-format mp3 -o 'public/audio/%(id)s.%(ext)s' #{@url}"
      io = IO::Memory.new
      Process.run command, shell: true, output: io
      output = io.to_s
      puts output
      rid = /v=(.*)$/.match(@url).try &.[1]
      @db.exec "insert into podcasts (rid, name) values (?, ?)", rid, ""
    end
  end
end
