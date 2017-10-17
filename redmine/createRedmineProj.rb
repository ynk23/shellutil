#!/usr/bin/ruby
# coding:utf-8
## Advance preparation
## Redmine: settings->certification->enable REST API

require 'net/http'

#check args
unless ARGV[0]
  puts "ERROR: invalid args. ARGS{0} is not exist."
  exit(1)
end

PJ_ID=ARGV[0]
PJ_NAME=ARGV[1]
#parent project : ***
##parent id : 1 - FIXED
PJ_PARENT=1

# print VAR
puts "arg1 : "+ARGV[0]+" | PJ_ID : "+"#{PJ_ID}"
puts "arg2 : "+ARGV[1]+" | PJ_NAME : "+"#{PJ_NAME}"

Net::HTTP::version_1_2

# create project
req = Net::HTTP::Post.new("/projects.xml")
req.basic_auth("admin", "admin")
req.content_type = "application/xml"

req.body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<project>
  <name>#{PJ_NAME}</name>
  <identifier>#{PJ_ID}</identifier>
  <parent_id>#{PJ_PARENT}</parent_id>
  <inherit_members>true</inherit_members>
  <scm>Git</scm>
</project>
"

Net::HTTP::start("<host>") { |http|
	res = http.request(req)

	if res.code.to_i != 201 then
		raise res.body
	end
}
