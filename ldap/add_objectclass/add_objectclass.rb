#!/usr/bin/env ruby1.9.3
# encoding: utf-8

require "net-ldap"
require "../../lib/config_reader.rb"
require "pathname"


config = read_config(Pathname.new("./config"), ["username","host","port","password"])

ldap = Net::LDAP.new :host => config[:host],
     :port => config[:port],
     :auth => {
           :method => :simple,
           :username => config[:username],
           :password => config[:password]
     }

filter = Net::LDAP::Filter.ne("objectClass", "piratenfraktion") & Net::LDAP::Filter.eq("objectClass", "person")
treebase = "dc=piratenfraktion-nrw,dc=de"

ldap.search(:base => treebase, :filter => filter) do |entry|
  uid = entry.uid[0]
  puts "uid: #{uid}"
  op = [
    [:add, :objectClass, ["piratenfraktion"]],
    [:add, :nick, [uid]]
  ]
  ldap.modify :dn => entry.dn, :operations => op
end


