#!/usr/bin/env ruby1.9.3
# encoding: utf-8

require "net-ldap"

File.open('config') do |f|
  re_host = /^host\s*=\s*"(\w+):(\d+)"$/
  re_username = /^username\s*=\s*"(.+)"$/
  re_password = /^password\s*=\s*"(.+)"$/
  
  line = f.read

  if line =~ re_host
    _host = line.match(re_host)
    @host = _host[1]
    @port = _host[2]
  elsif line =~ re_username
    @username = line.match(re_username)[1]
  elsif line =~ re_password
    @password = line.match(re_password)[1]
  end
end

ldap = Net::LDAP.new :host => @host,
     :port => @port,
     :auth => {
           :method => :simple,
           :username => @username,
           :password => @password
     }

filter = Net::LDAP::Filter.eq("telephoneNumber", "*")
treebase = "dc=piratenfraktion-nrw,dc=de"

ldap.search(:base => treebase, :filter => filter) do |entry|
  puts "DN: #{entry.dn}"
  puts "telephoneNumber: #{entry.telephoneNumber}"
  if entry.telephoneNumber[0] =~ /\d{4}/
    new_number = "+49211884" + entry.telephoneNumber[0]
    puts new_number
    op = [
      [:replace, :telephoneNumber, [new_number]]
    ]
    ldap.modify :dn => entry.dn, :operations => op
  end
end


