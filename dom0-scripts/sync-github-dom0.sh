#!/bin/bash
# Name   : copy-github-dom0
# Purpose: Copies a github-repository to dom0 and vica versa
# Usage  : copy-github-dom0 - options are set in this script
# Author : one7two99@gmail.com
# Date   : 29.06.20
 
AppVM=my-untrusted
GithubAccount=one7two99
GithubRepo=my-qubes

case "$1" in

'download')
  # Clone repository to a /tmp location in AppVM
  qvm-run --pass-io --no-gui $AppVM \
    "mkdir -p /tmp/repo && cd /tmp/repo && \
     git clone https://github.com/$GithubAccount/$GithubRepo.git"

  # Copy data to dom0
  rm -Rf ~/$GithubRepo
  qvm-run --pass-io --no-gui $AppVM \
    "cd /tmp/repo && tar -czf - --exclude=./$GithubRepo/.git ./$GithubRepo" | tar xvfz -

  # Remove temporary repository
  qvm-run --pass-io --no-gui $AppVM \
    "rm -Rf /tmp/repo"
  ;;

'upload')
  # Clone repository to a /tmp location in AppVM
  qvm-run --pass-io --no-gui $AppVM \
    "mkdir -p /tmp/repo && cd /tmp/repo && \
     git clone git@github.com:$GithubAccount/$GithubRepo.git"

   # Copy repository from dom0 to AppVM (overwritting old files)
   cd ~/
   tar -czf - $GithubRepo | qvm-run --pass-io --no-gui $AppVM "tar -xvzf - -C /tmp/repo"

  # Push changes to github
  qvm-run --pass-io --no-gui $AppVM \
    "cd /tmp/repo/$GithubRepo && \
     git add . && \
     git status && \
     git commit -a -m Upload && \
     git push"

  # Remove temporary repository
  qvm-run --pass-io --no-gui $AppVM \
    "rm -Rf /tmp/repo"
  ;;

*)
  echo
  echo "Usage: sync-github-dom0 upload|download"
  echo
  ;;
esac
