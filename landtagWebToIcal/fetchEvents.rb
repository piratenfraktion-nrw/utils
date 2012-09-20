#!/usr/bin/env ruby1.9.3

require 'rubygems'
require 'nokogiri'   
require 'open-uri'
require 'icalendar'
require 'date'

include Icalendar

calAusschusssitzung = Calendar.new
calPlenarsitzung = Calendar.new
calRest = Calendar.new

PAGE_URL = "http://www.landtag.nrw.de/portal/WWW/Webmaster/GB_I/I.1/Aktuelle_Termine.jsp?mmerk=1&typ=aktuell&ausschuss=alle&maxRows=1000"

page = Nokogiri::HTML(open(PAGE_URL))
   
page.css("#content table tr").each do |row|
    row = Nokogiri::HTML(row.to_s)
    i = 0
    date = ""
    summary = ""
    row.css("td").each do |cell|
        date = cell.inner_text.strip if i == 0
        summary = cell.inner_text.strip if i == 1
        i += 1
    end
    if date != ""
        event = Event.new
        event.start = DateTime.strptime(date, "%d.%m.%Y,%H:%M")
        event.summary = summary
        if summary =~ /Plenarsitzung/
            calPlenarsitzung.add_event(event)
        elsif summary =~ /Ausschusssitzung/
            calAusschusssitzung.add_event(event)
        else
            calRest.add_event(event)
        end
    end
end

File.open('ausschusssitzung.ics', 'w') do |f|
   f.write(calAusschusssitzung.to_ical) 
end

File.open('plenarsitzung.ics', 'w') do |f|
   f.write(calPlenarsitzung.to_ical) 
end

File.open('rest.ics', 'w') do |f|
   f.write(calRest.to_ical) 
end

