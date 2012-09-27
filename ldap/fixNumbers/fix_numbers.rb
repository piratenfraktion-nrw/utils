#!/usr/bin/env ruby1.9.3
# encoding: utf-8

require "net-ldap"

ldap = Net::LDAP.new :host => "localhost",
     :port => 3389,
     :auth => {
           :method => :simple,
           :username => "cn=admin,dc=piratenfraktion-nrw,dc=de",
           :password => "setme"
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


