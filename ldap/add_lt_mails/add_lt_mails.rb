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
filter = filter & Net::LDAP::Filter.eq('mail', '*@landtag.nrw.de')
filter = filter & Net::LDAP::Filter.ne('uid', 'admin')
filter = filter & Net::LDAP::Filter.ne('uid', 'spam.8t9gvsbsm')
filter = filter & Net::LDAP::Filter.ne('uid', 'virus-quarantine.dw68b_tg1')
filter = filter & Net::LDAP::Filter.ne('uid', 'galsync.zlkph5tjlt')
filter = filter & Net::LDAP::Filter.ne('uid', 'zimbradummy')
filter = filter & Net::LDAP::Filter.ne('uid', 'ham.rccyucgc9')

treebase = "ou=people,dc=piratenfraktion-nrw,dc=de"

ldap.search(:base => treebase, :filter => filter) do |entry|
  uid = entry.uid[0]
  puts "uid: #{uid}"
  lt_mail = "#{entry[:givenName][0]}.#{entry[:sn][0]}@landtag.nrw.de"
  lt_mail = lt_mail.gsub(' ', '-').gsub('ö','oe').gsub('ü', 'ue').gsub('ä', 'ae').gsub('ø','o').gsub('é', 'e').gsub('ß','ss').downcase
  puts lt_mail
  op = [
    [:add, :zimbraMailAlias, [lt_mail]],
    [:add, :mail, [lt_mail]]
  ]
  ldap.modify :dn => entry.dn, :operations => op
end


