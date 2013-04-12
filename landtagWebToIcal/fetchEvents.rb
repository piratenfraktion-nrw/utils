#!/usr/bin/env ruby1.9.3

require 'rubygems'
require "bundler/setup"
require 'nokogiri'   
require 'open-uri'
require 'icalendar'
require 'date'
require "slugify"

include Icalendar

calendars = {}

calendars[:Plenarsitzung] = Calendar.new
calendars[:Rest] = Calendar.new
calendars[:Alles] = Calendar.new

PAGE_URL = "http://www.landtag.nrw.de/portal/WWW/Webmaster/GB_I/I.1/Aktuelle_Termine.jsp?mmerk=1&typ=aktuell&ausschuss=alle&maxRows=1000"


%x(rm /sites/cal/public/**/*.ics)

page = Nokogiri::HTML(open(PAGE_URL))

page.css("#content table tr").each do |row|
    row = Nokogiri::HTML(row.to_s)
    date = ""
    summary = ""

    row.css("td").each_with_index do |cell,i|
        date = cell.inner_text.strip if i == 0
        summary = Nokogiri.HTML(cell.inner_html.gsub(/<br\/?>/, '-')).inner_text.strip if i == 1
    end

    unless date.empty? and summary.empty?
        event = Event.new
        event.start = DateTime.strptime(date, "%d.%m.%Y,%H:%M")
        if event.start >= DateTime.strptime("13.05.2012", "%d.%m.%Y")
            event.summary = summary
            ausschussMatches = summary.match(/\d+\.\sAusschusssitzung\s-\s(.*)/)

            if !ausschussMatches.nil?
                @ausschussName = ausschussMatches[1].slugify
                if calendars[@ausschussName].nil?
                    calendars[@ausschussName] = Calendar.new
                end
            end

            if summary =~ /Plenarsitzung/
                calendars[:Plenarsitzung].add_event(event)
            elsif summary =~ /Ausschusssitzung/
                calendars[@ausschussName].add_event(event)
            else
                calendars[:Rest].add_event(event)
            end

            calendars[:Alles].add_event(event)
        end
    end
end

def write_ics(file, cal)
    File.open("/sites/cal/public/landtag/#{file}.ics", 'w') do |f|
        f.write(cal.to_ical) 
    end
end

calendars.each_pair do |key, value|
    write_ics key, value
end

