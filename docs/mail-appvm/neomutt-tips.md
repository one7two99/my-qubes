# Neomutt Tipps

## Configuration

add `source personal.muttrc` to ~/.confgi/mutt/muttrc to include a personal mutt configuration file.

If you work with Mailinglists, add the following lines to ~/.config/mutt/personal.muttrc
```
### my personal mutt settings
# Documentation:  neomutt - Configuration
# https://www.neomutt.org/guide/configuration

# Definition of mailinglists
subscribe qubes-users@googlegroups.com

# Use own headers
#ignore *
#unignore from date subject to cc
#unignore organization organisation x-mailer: x-newsreader: x-mailing-list:
#unignore posted-to:

set editor = nano
```

## Keyboard shortcuts


### Main window

- D = Delete mail
- m = Write new mail
- r = Reply to mail
- L = Reply to list (Lists must be setup in muttrc via `subscribe <LIST>`

### Navigation Folders
Ctrl + K	go one folder up
Ctrl + J	go one folder down
Ctrl + O	Open selected folder
