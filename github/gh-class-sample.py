#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import codecs
import argparse
import pprint
import requests
from attrdict import AttrDict
import urllib.parse

class restapi(object):
    @staticmethod
    def get(url):
        print('[info]get request: '+url)
        response = requests.get(url)
        list = response.json()
        if('next' in response.links):
            next = AttrDict(response.links['next'])
            nextlist = restapi.get(next.url)
            if(nextlist):
                list.extend(nextlist)
            return list
        else:
            return list

    @staticmethod
    def delete(url):
        print('[info]delete request: '+url)
        response = requests.delete(url)
        if(response.status_code is 204):
            print('[info]result: deleted')
        else:
            print('[error]error occured in deleting')
            print(response)

class requestbuilder(object):
    @staticmethod
    def build(dict):
        return urllib.parse.urlencode(dict)

class github(object):
    def __init__(self, hostname):
        self.hostname = hostname
        if(hostname is 'github.com'):
            self.endpoint = 'https://api.'+hostaname
        else:
            self.endpoint = 'https://'+hostname+'/api/v3'

    def getmembers(self, org):
        getmembers_url = self.endpoint+'/orgs/'+org+'/members?per_page=100&role=member'
        return restapi.get(getmembers_url)

    def getrepos(self, org):
        getrepos_url = self.endpoint+'/orgs/'+org+'/repos?per_page=100'
        return restapi.get(getrepos_url)

    def getissues(self, org, repo, query):
        param = requestbuilder.build(query)
        getissues_url = self.endpoint+'/repos/'+org+'/'+repo+'/issues?per_page=100&'+param
        return restapi.get(getissues_url)

    def removemembers(self, org):
        members = self.getmembers(org)
        for member in members:
            # dict型にattributeアクセスできるように変換
            member = AttrDict(member)
            deletemember_url = self.endpoint+'/orgs/'+org+'/members/'+member.login
            restapi.delete(deletemember_url)

    def deleterepos(self, org):
        repos = self.getrepos(org)
        for repo in repos:
            # dict型にattributeアクセスできるように変換
            repo = AttrDict(repo)
            deleterepo_url = self.endpoint+'/repos/'+org+'/'+repo.name
            restapi.delete(deleterepo_url)

def main():
    print(sys.getdefaultencoding())
    print(sys.stdout.encoding)
    parser = argparse.ArgumentParser()
    parser.add_argument('--hostname',type=str,required=True,help='github host name. e.g. github.com')
    args = parser.parse_args()
    gh = github(args.hostname)
    query = {'state':'all'}
    issues = gh.getissues('org','repo',query)
    with codecs.open('issue.txt', 'w', 'utf-8') as f:
        for issue in issues:
            issue = AttrDict(issue)
            title = issue.title
            f.write(title+'\n')

if __name__ == '__main__':
    main()
