#!/usr/bin/env ruby1.9.3
# encoding: utf-8

require "net-ldap"
require "../../lib/config_reader.rb"


config = read_config("config", ["username","host","port","password"])

ldap = Net::LDAP.new :host => @host,
     :port => config[:port],
     :auth => {
           :method => :simple,
           :username => config[:username],
           :password => config[:password]
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


