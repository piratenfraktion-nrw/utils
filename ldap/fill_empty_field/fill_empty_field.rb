#!/usr/bin/env ruby
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

filter = Net::LDAP::Filter.eq("objectClass", "piratenfraktion") & Net::LDAP::Filter.eq("objectClass", "person")
filter = filter & Net::LDAP::Filter.ne('uid', 'admin')
filter = filter & Net::LDAP::Filter.ne('uid', 'spam.8t9gvsbsm')
filter = filter & Net::LDAP::Filter.ne('uid', 'virus-quarantine.dw68b_tg1')
filter = filter & Net::LDAP::Filter.ne('uid', 'galsync.zlkph5tjlt')
filter = filter & Net::LDAP::Filter.ne('uid', 'zimbradummy')
filter = filter & Net::LDAP::Filter.ne('uid', 'ham.rccyucgc9')
treebase = "ou=people,dc=piratenfraktion-nrw,dc=de"

ldap.search(:base => treebase, :filter => filter) do |entry|
  if entry[ARGV[0]].length == 0 || ARGV[2] == "all"
    puts "uid: #{entry.uid[0]} = #{entry[ARGV[0]][0]}"
    if ARGV[2] != "demo"
      op = [[:replace, ARGV[0], [ARGV[1]]]]
      ldap.modify :dn => entry.dn, :operations => op
    end
  end
end


