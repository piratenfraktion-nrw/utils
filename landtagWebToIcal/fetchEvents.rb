#!/usr/bin/env ruby1.9.3

require 'rubygems'
require "bundler/setup"
require 'nokogiri'   
require 'open-uri'
require 'icalendar'
require 'date'

include Icalendar

@calAusschusssitzung = Calendar.new
@calPlenarsitzung = Calendar.new
@calRest = Calendar.new

PAGE_URL = "http://www.landtag.nrw.de/portal/WWW/Webmaster/GB_I/I.1/Aktuelle_Termine.jsp?mmerk=1&typ=aktuell&ausschuss=alle&maxRows=1000"

page = Nokogiri::HTML(open(PAGE_URL))

page.css("#content table tr").each do |row|
    row = Nokogiri::HTML(row.to_s)
    date = ""
    summary = ""
    row.css("td").each_with_index do |cell,i|
        date = cell.inner_text.strip if i == 0
        summary = cell.inner_text.strip if i == 1
    end
    unless date.empty? and summary.empty?
        event = Event.new
        event.start = DateTime.strptime(date, "%d.%m.%Y,%H:%M")
        event.summary = summary
        if summary =~ /Plenarsitzung/
            @calPlenarsitzung.add_event(event)
        elsif summary =~ /Ausschusssitzung/
            @calAusschusssitzung.add_event(event)
        else
            @calRest.add_event(event)
        end
    end
end

def write_ics(file)
    File.open("#{file}.ics", 'w') do |f|
        f.write(eval("@cal#{file.capitalize}").to_ical) 
    end
end

write_ics 'plenarsitzung'
write_ics 'rest'
write_ics 'ausschusssitzung'

