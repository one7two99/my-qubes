# Jekyll plain text blogging
Further reading
- https://developer.fedoraproject.org/start/sw/web-app/jekyll.html
- https://jekyllrb.com/docs/usage/
- https://jekyllrb.com/docs/github-pages/

- https://help.github.com/articles/setting-up-your-github-pages-site-locally-with-jekyll/
- https://jekyllrb.com/docs/quickstart/
- https://pages.github.com/


## Installation on Fedora 26:
Link: https://help.github.com/articles/setting-up-your-github-pages-site-locally-with-jekyll/

1. Install ruby, rubygems and bundler:
```
sudo dnf install ruby-devel rubygem-json rubygems
gem install bundler
```
2. Create a Gemfile with the following two lines:
```
source 'https://rubygems.org' > Gemfile
gem 'github-pages', group: :jekyll_plugins >> Gemfile
```
3. Install Jekyll and dependencies
```
bundle install
gem install jekyll
```
This will leave a Gemfile.lock in your directory
4. Create a local Jekyll-Installation in a new subdirectory
```
bundle exec jekyll _3.3.0_ new one7two99.github.io
```
5. Change to this directory
```
cd one7two99.github.io
```
6. Edit your Gemfile
remove the following line:
```
"jekyll", "3.3.0"
```
delete the # at the beginning of this line:
```
gem "github-pages", group: :jekyll_plugins
```
7. Initialize your site directory as a Git repository.
```
git init
```
8. create a new repository as Github pages
Link: https://github.com/new
The new repository must be named like <YOUR-GIT-USER-NAME>.github.io
In our example: one7two99.github.io
Copy the SSH link to the clipboard:
```
git@github.com:one7two99/one7two99.github.io.git
```
9. Connect your remote repository on GitHub to your local repository for your GitHub Pages site.
```
git remote add origin https://github.com/username-or-organization-name/your-remote-repository-name
```
10. Edit your Jekyll-site locally
tweak the text files to implement first changes.
You can preview your changes by running
```
bundle exec jekyll serve
```
11. Add or stage your changes.
```
git add .
```
12. Commit your changes with a comment.
```
git commit -m "updated site"
```
13. publish your changes on your GitHub Pages site
```
git push -u origin master
```









## Create a new site
1. create a new jekyll-site
  ```
  jekyll new my-jekyll
  cd my-jekyll
  jekyll serve
  ```
2. browse to http://localhost:4000
