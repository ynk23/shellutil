#!/usr/bin/ruby
### encoding: utf-8
###
### RedmineからREST APIを使ってユーザーの一覧を取得する
###

require 'bundler'
Bundler.require

require 'rubygems'
require 'active_resource'

QUERY_GROUP = ['BP','admin']

## User model on the client side
class User < ActiveResource::Base
  self.site = 'http://myhost'
  self.headers["X-Redmine-API-Key"] = '<api-key>'
  self.collection_name = "users"
  self.element_name = "user"
  self.format = :xml
end

# Retrieving users
users = User.find(:all)
users.each do |user|
  uid = user.id
  userfull = User.find(uid, :params => { :include => "groups" })
  groups = Array.new
  userfull.groups.each do |g|
    groups << g.name
  end
  match_group=[groups, QUERY_GROUP].inject{|ary1, ary2| ary1 & ary2}
  if match_group === QUERY_GROUP then
    puts user.id+"\t"+user.lastname+' '+user.firstname+"\t"+user.mail+"\t"+groups.join(',')
  end
  groups.clear
end
