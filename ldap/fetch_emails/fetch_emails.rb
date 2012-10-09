#!/usr/bin/env ruby1.9.3
# encoding: utf-8

require "net-ldap"
require "../../lib/config_reader.rb"
require "pathname"

config = read_config(Pathname.new("./config"), ["username","host","port","password"])

puts config.inspect

ldap = Net::LDAP.new :host => config[:host],
     :port => config[:port],
     :auth => {
           :method => :simple,
           :username => config[:username],
           :password => config[:password]
     }

filter = Net::LDAP::Filter.eq("mail", "*")
treebase = "ou=people,dc=piratenfraktion-nrw,dc=de"

ldap.search(:base => treebase, :filter => filter) do |entry|
  puts "#{entry.mail[0]}"
end


