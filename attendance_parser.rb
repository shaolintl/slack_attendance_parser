require 'bundler/inline'
require 'json'
require 'date'
require "csv"
gemfile do
  source 'https://rubygems.org'
end

users = {}
File.open("data/users.json", "r+") do |fname|
  uarray = JSON.parse(File.read(fname))
  uarray.each do |msg|
    users[msg["id"]] = msg["real_name"]
  end
end

attendance = {}
reg = /attendance for (.*)/i
Dir["data/attendance/*"].each do |fname|
  aarray = JSON.parse(File.read(fname))
  aarray.each do |msg|
    text = msg["text"]
    mtch = reg.match text
    if mtch
      date = mtch[1]
      attendance[date] = {}
      replies = msg["replies"]
      unless replies.nil?
        replies.each do | reply |
          attendance[date][reply["user"]] = DateTime.strptime(reply["ts"],'%s')
        end
      end
    end
  end
end

CSV.open("attendance.csv", "wb") do |csv|
  dates = attendance.keys.sort do | a, b |
    a = DateTime.strptime(a, '%d/%m')
    b = DateTime.strptime(b, '%d/%m')
    a <=> b
  end
  csv << ["Name"] + dates
  users.each do | key, name |
    arr = dates.map do | date |
      if attendance[date].key?(key)
        attendance[date][key].strftime("%I:%M%p")
      else
        ""
      end
    end
    csv << arr.unshift(name)
  end
end
