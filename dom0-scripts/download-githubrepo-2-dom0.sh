#!/bin/bash
# name: download-githubrepo-2-dom0.sh
#       Script to download a GitHub repository to dom0
# date: 2021/11/28
# link: https://github.com/one7two99/my-qubes/edit/master/dom0-scripts/sync-github-dom0.sh

MyRepo=https://github.com/one7two99/my-qubes/archive/refs/heads/master.zip
MyRepoName=my-qubes
AppVM=my-untrusted

rm -Rf ~/$MyRepoName
qvm-run --pass-io --no-gui $AppVM "wget $MyRepo"
qvm-run --pass-io --no-gui $AppVM "unzip master.zip && rm master.zip"
qvm-run --pass-io --no-gui $AppVM "tar -czf - *master*" | tar xvfz -
qvm-run --pass-io --no-gui $AppVM "rm -Rf *master*"
mv ~/$MyRepoName-master ~/$MyRepoName
