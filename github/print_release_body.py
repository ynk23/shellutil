# -*- coding: utf-8 -*-

# 利用パッケージ
#   - github3.py
#

import re
from github3 import GitHubEnterprise

token = ""		# access token for github
api_url = "https://enterprise.github/api/v3"		# github api endpoint
html_url = "https://enterprise.github/"			# github url
org_name = "foo"										# organization name
repository_list_file = "./release_repo_list.txt"		# file of release repository list
release_repos = []										# list of release repository

def checktype(obj):
	if isinstance(obj, bool):
		print('bool型です')
	elif isinstance(obj, int):
		print('int型です')
	elif isinstance(obj, float):
		print('float型です')
	elif isinstance(obj, complex):
		print('complex型です')
	elif isinstance(obj, list):
		print('list型です')
	elif isinstance(obj, tuple):
		print('tuple型です')
	elif isinstance(obj, range):
		print('range型です')
	elif isinstance(obj, str):
		print('str型です')
	elif isinstance(obj, set):
		print('set型です')
	elif isinstance(obj, frozenset):
		print('frozenset型です')
	elif isinstance(obj, dict):
		print('dict型です')
	else:
		print('当てはまる型がありません')

def read_file(file):
	try:
		with open(file,'r',encoding='UTF-8') as f:
			for line in f:
				element = line.rstrip()		# 改行を削除
				if re.match(r"^#", element):
					continue
				else:
					release_repos.append(element)
		return release_repos
	except:
		print("ファイルが存在しません ",repository_list_file)
		return release_repos

def print_all_releases(repo):
	for rel in repo.releases():
		print("print relese: ",rel.tag_name)
		file_name = 'rels/' + rel.tag_name
		f = open(file_name, 'w')
		f.write(rel.body)
		print(">>>write: ",file_name)
		f.close()

if __name__ == '__main__':
	gh = GitHubEnterprise(url=html_url,token=token)
	org = gh.organization(org_name)
	repos = org.repositories()					# get all repositories in organization
	rel_repos = read_file(repository_list_file)	# read release repository
	if len(rel_repos) == 0:
		print("exit")
		sys.exit(1)
	for repo in repos:
		if repo.name in rel_repos:				# get only if release_repos
			print(">>> --- start ",repo.name," ---")
			print_all_releases(repo)
