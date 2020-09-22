dotfiles
========

The setting files for my development PC.

## Usage

Work with homebrew and Ansible. Install necessary packages, make symlinks of dotfiles, and set up some environments for development.

```bash
$ mkdir -p ~/repos/src/github/com/chroju
$ cd ~/repos/src/github/com/chroju
$ git clone https://github.com/chroju/dotfiles
$ cd dotfiles
$ ansible-playbook playbook.yml -K
```

## Author

chroju <http://chroju.net>
