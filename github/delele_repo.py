# -*- coding: utf-8 -*-

# 利用パッケージ
#   - PyGithub
#

from github import Github

token = ""
api_url = "https://enterprise.github/api/v3"
html_url = "https://enterprise.github/"
org_name = "foo"
del_list = [ "bar" "baz" ]

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

def searchrepos(owner,repo_list):
	# get repositories:
	print('-----------')
	print(owner.html_url)
	print('-----------')
	repos = []
	for repo in owner.get_repos():
		if(repo.name in repo_list): repos.append(repo)
	return repos

def delrepos(repos):
	for repo in repos:
		print("DELETE: "+repo.name)
		repo.delete()

if __name__ == '__main__':
	github = getinstance()
	orgs = getorgs(github)
	org = searchorg(orgs,org_name)
	repos = searchrepos(org,del_list)
	delrepos(repos)
