# install pinentry-gtk in template VM
echo "pinentry-program /usr/bin/pinentry-gtk" > ~/.gnupg/gpg-agent.conf 
gpg-connect-agent reloadagent /bye
