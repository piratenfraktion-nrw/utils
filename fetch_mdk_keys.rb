#!/usr/bin/env ruby
#encoding: utf-8

mdl_file = '/home/vileda/Documents/pfnrw/mdl_gpg_keys.txt'

File.open(mdl_file) do |f|
  f.each_line do |l|
    res = %x[keylookup --frontend=text '#{l}' 2> /dev/null]
    puts "#{l.strip}:"
    found_keys = res.scan(/\d{4}\w\/(.{8}).*/)
    key = "Kein(e) Key(s) gefunden"
    key = found_keys.map {|r| "0x#{r[0]}"}.join("\n") if found_keys.length > 0
    puts key
    puts ""
    sleep(3.0)
  end
end
