FROM ubuntu:trusty
MAINTANER Kamil Trzciński <ayufan@ayufan.eu>

RUN apt-get update -y
RUN apt-get install -y sudo build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev logrotate git-core ruby2.0-dev bundler mysql-client libmysqlclient-dev openssh-server

RUN apt-get install -y ca-certificates supervisor

RUN adduser --disabled-login --gecos 'GitLab' git

RUN curl https://github.com/gitlabhq/gitlabhq/archive/v6.8.1.tar.gz | tar -zx -C /home/git/ && \
	mv gitlabhq-6.8.1 gitlab

RUN curl https://github.com/gitlabhq/gitlab-shell/archive/v1.9.4.tar.gz | tar -zx -C /home/git/ && \
	mv gitlab-shell-1.9.4 gitlab-shell

ADD gitlab/ /home/git/gitlab/config/
ADD gitlab-shell/ /home/git/gitlab-shell/

RUN chown -R git /home/git/gitlab/log/ && \
	chown -R git /home/git/gitlab/tmp/ && \
	chmod -R u+rwX /home/git/gitlab/log/ && \
	chmod -R u+rwX /home/git/gitlab/tmp/ && \
	chmod -R u+rwX /home/git/gitlab/tmp/pids/ && \
	chmod -R u+rwX /home/git/gitlab/tmp/sockets/ && \
	chmod -R u+rwX /home/git/gitlab/public/uploads

RUN mkdir /home/git/gitlab-satellites && \
	chown -R git /home/git/gitlab-satellites && \
	chmod u+rwx,g+rx,o-rwx /home/git/gitlab-satellites

USER git

RUN git config --global user.name "GitLab" && \
	git -H git config --global user.email "gitlab@localhost" && \
	git config --global core.autocrlf input

WORKDIR /home/git/gitlab
RUN bundle install --deployment --without development test postgres aws
RUN bundle exec rake assets:precompile RAILS_ENV=production

WORKDIR /home/git/gitlab-shell
RUN bundle install --deployment
