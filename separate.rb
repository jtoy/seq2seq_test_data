require 'json'

f = File.read("mongo_dump.json").force_encoding("utf-8")
json = []
f.each_line do |line|
  json << JSON.parse(line)["body"]
end

firsts = []
responses = []
json.each_with_index do |line, i|
  if i % 100 == 0
    puts "Cleansing and splitting email conversation ##{i}/#{json.length}"
  end

  s=line.split(/Original Message|Reply Separator|Forwarded|Subject|Re:/i)
  s=s.map{|s| s.strip}.map { |s| s.tr("-","")}.map{|s| s.tr("_","")}.map{|s| s.tr(":", "")}.map{|s| s.tr("=","")}.map{|s| s.strip}.reject{|s| s.empty?}
  s=s.reject{|p| p.split("\n").all? {|l| l.start_with?("From", "Sent", "To", "Subject", "Cc")}}

  if s.length == 1
    next
  else
    s.each_with_index do |part, i|
      if i == s.length - 1
        responses << part
      elsif i == 0
        firsts << part
      else
        firsts << part
        responses << part
      end
    end
  end
end

first_file = File.open("first.txt", "w")
response_file = File.open("last.txt", "w")
firsts.each_with_index do |l, i|
  if i % 100 == 0
    puts "Writing line #{i}/#{firsts.length} to firsts file"
  end

  first_file.puts l.dump
end

responses.each_with_index do |l, i|
  if i % 100 == 0
    puts "Writing line #{i}/#{responses.length} to response file"
  end

  response_file.puts l.dump
end
