#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'media_wiki'
require 'active_resource'
require 'erb'
require 'open-uri'

if ARGV.length != 2
    puts "usage: padbot_bot <username> <password>"
    exit(-1)
end

USERNAME = ARGV[0]
PASSWORD = ARGV[1]

protokolle = {
'Fraktionssitzung/2013-04-23' => 'https://20piraten.piratenpad.de/ep/pad/export/766/latest?format=txt',
'Fraktionssitzung/2013-04-16' => 'https://20piraten.piratenpad.de/ep/pad/export/749/latest?format=txt',
'Fraktionssitzung/2013-04-09' => 'https://20piraten.piratenpad.de/ep/pad/export/741/latest?format=txt',
'Fraktionssitzung/2012-11-13' => 'https://20piraten.piratenpad.de/ep/pad/export/121/latest?format=txt',
'Fraktionssitzung/2012-02-19' => 'https://20piraten.piratenpad.de/ep/pad/export/701/latest?format=txt',
'Fraktionssitzung/2012-02-15' => 'https://20piraten.piratenpad.de/ep/pad/export/697/latest?format=txt',
'Fraktionssitzung/2012-12-11' => 'https://20piraten.piratenpad.de/ep/pad/export/222/latest?format=txt',
'Fraktionssitzung/2012-12-04' => 'https://20piraten.piratenpad.de/ep/pad/export/219/latest?format=txt',
'Fraktionssitzung/2012-11-27' => 'https://20piraten.piratenpad.de/ep/pad/export/217/latest?format=txt',
'Fraktionssitzung/2013-01-29' => 'https://20piraten.piratenpad.de/ep/pad/export/678/latest?format=txt',
'Fraktionssitzung/2013-01-15' => 'https://20piraten.piratenpad.de/ep/pad/export/253/latest?format=txt',
'Fraktionssitzung/2013-01-22' => 'https://20piraten.piratenpad.de/ep/pad/export/673/latest?format=txt',
'Fraktionssitzung/2013-01-08' => 'https://20piraten.piratenpad.de/ep/pad/export/254/latest?format=txt'
}

print "login to MediaWiki..."

mw = MediaWiki::Gateway.new('https://wiki.piratenfraktion-nrw.de/api.php')
mw.login(USERNAME, PASSWORD, 'Piratenfraktion NRW')

puts "done"

protokolle.each do |name, url|
    print "fetching #{name}..."
    page_name = 'Protokoll:' + name
    contents = URI.parse(url).read
    print("done\nediting...")
    mw.edit(page_name, contents, :summary => 'PadBot')
    puts "done"
end

