#!/usr/bin/env ruby
# encoding: utf-8

require "net-ldap"
require "../../lib/config_reader.rb"
require "pathname"
require "builder"

config = read_config(Pathname.new("./config"), ["username","host","port","password"])

ldap = Net::LDAP.new :host => config[:host],
     :port => config[:port],
     :auth => {
           :method => :simple,
           :username => config[:username],
           :password => config[:password]
     }

filter = Net::LDAP::Filter.eq("objectClass", "piratenfraktion")
treebase = "ou=people,dc=piratenfraktion-nrw,dc=de"

xml = Builder::XmlMarkup.new( :indent => 2 )
xml.instruct! :xml, :encoding => "UTF-8"

users = ""

xml.ZCSImport do |imp|
  imp.ImportUsers do |imp_user|
    ldap.search(:base => treebase, :filter => filter) do |entry|
        users += "#{entry.uid[0]} "
      #imp_user.User do |user|
        #users += "#{entry.uid[0]} "
        #user.uid(entry.uid[0])
        #user.sn(entry.sn[0])
        #user.cn(entry.cn[0])
        #if !entry[:givenName][0].nil?
        #  user.givenName(entry[:givenName][0])
        #else
        #  user.givenName(entry[:cn][0])
        #end

        #if !entry[:displayName][0].nil?
        #  user.displayName(entry[:displayName][0])
        #else
        #  user.displayName(entry[:cn][0])
        #end

        #user.nick(entry[:nick][0]) if entry[:nick][0]
        #user.roomNumber(entry[:roomNumber][0]) if entry[:roomNumber][0]
        #user.telephoneNumber(entry[:telephoneNumber][0]) if entry[:telephoneNumber][0]
        #user.facsimileTelephoneNumber(entry[:facsimileTelephoneNumber][0]) if entry[:facsimileTelephoneNumber][0]
        #user.description(entry[:description][0]) if entry[:description][0]
        #user.mobile(entry[:mobile][0]) if entry[:mobile][0]
        #user.RemoteEmailAddress("#{entry.uid[0]}@piratenfraktion-nrw.de")
        #user.password("foobar123")
        #user.userPassword(entry[:userPassword][0])
        #user.zimbraPasswordMustChange("FALSE")
      #end
    end
  end
end

puts users

#puts xml.target

