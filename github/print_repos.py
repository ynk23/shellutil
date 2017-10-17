#!/usr/bin/env python
# -*- coding: utf-8 -*-

from github import Github

token = ""
api_url = ""
html_url = ""

def getinstance():
	# First create a Github instance:
	return Github(login_or_token=token, password=None, base_url=api_url, timeout=10, client_id=None, client_secret=None, user_agent='PyGithub/Python', per_page=30, api_preview=False)

def getorgs(gh):
	# get organizations:
	return gh.get_user().get_orgs()

def searchorg(orgs,name):
	for org in orgs:
		# org.name が None になるのでurl名でフィルタリング
		if(org.html_url == html_url+name ):
			return org

def listrepos(owner):
	# get repositories:
	print('-----------')
	print(owner.html_url)
	print('-----------')
	for repo in owner.get_repos():
		print(repo.name)

def getrepos(gh):
	# Then play with your Github objects:
	for repo in gh.get_user().get_repos():
		print(repo.name)

if __name__ == '__main__':
	github = getinstance()
	orgs = getorgs(github)
	org = searchorg(orgs,'trial-mfp')
	listrepos(org)
