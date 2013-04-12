#!/usr/bin/env ruby
# encoding: utf-8

require "net-ldap"
require "../../lib/config_reader.rb"
require "pathname"
require 'digest/sha1'
require 'base64'


def add_single_op(dn, ldap, field, src, src_field = nil)
  data = src_field.nil? ? src[field] : src[src_field]
  if data
    data.each do |v|
      puts v
      ldap.modify :dn => dn, :op => [[:add, field, [v]]]
    end
  end
end

def add(ldap, field, src, src_field = nil)
  data = src_field.nil? ? src[field] : src[src_field]
  if data
    [:add, field, data]
  end
end

def replace_single(ldap, field, value)
  if value
    [:replace, field, [value]]
  end
end

def replace(ldap, field, src)
  if src[field]
    [:replace, field, src[field]]
  end
end

config_src = read_config(Pathname.new("./config_src"), ["username","host","port","password"])
config_dest = read_config(Pathname.new("./config_dest"), ["username","host","port","password"])

ldap_src = Net::LDAP.new :host => config_src[:host],
     :port => config_src[:port],
     :auth => {
           :method => :simple,
           :username => config_src[:username],
           :password => config_src[:password]
     }

ldap_dest = Net::LDAP.new :host => config_dest[:host],
     :port => config_dest[:port],
     :auth => {
           :method => :simple,
           :username => config_dest[:username],
           :password => config_dest[:password]
     }


filter_src = Net::LDAP::Filter.eq("objectClass", "piratenfraktion")
treebase = "dc=piratenfraktion-nrw,dc=de"

ldap_src.search(:base => treebase, :filter => filter_src) do |entry_src|
  uid = entry_src.uid[0]
  filter_dest = Net::LDAP::Filter.eq("uid", uid)
  puts "uid: #{uid}"
  ldap_dest.search(:base => treebase, :filter => filter_dest) do |entry_dest|
    puts "uid: #{entry_src.uid[0]}"
    op = []
    password = entry_src[:userPassword][0]
    password = '{SHA}' + Base64.encode64(Digest::SHA1.digest("foobar123")).chomp! if password.nil?
    op << replace_single(ldap_dest, :userPassword, password)
    ldap_dest.modify :dn => entry_dest.dn, :operations => op
  end
end


