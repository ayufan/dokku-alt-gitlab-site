FROM ubuntu:trusty
MAINTANER Kamil Trzciński <ayufan@ayufan.eu>

RUN apt-get update -y
RUN apt-get install -y sudo build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev logrotate git-core ruby2.0-dev bundler mysql-client libmysqlclient-dev openssh-server

RUN apt-get install -y ca-certificates supervisor

RUN adduser --disabled-login --gecos 'GitLab' git

WORKDIR /home/git

RUN curl -L https://github.com/gitlabhq/gitlabhq/archive/v6.8.1.tar.gz | tar -zx && \
	mv gitlabhq-6.8.1 gitlab

RUN curl -L https://github.com/gitlabhq/gitlab-shell/archive/v1.9.4.tar.gz | tar -zx && \
	mv gitlab-shell-1.9.4 gitlab-shell

ADD gitlab/ gitlab/config/
ADD gitlab-shell/ gitlab-shell/

RUN chown -R git gitlab/log/ && \
	chown -R git gitlab/tmp/ && \
	chmod -R u+rwX gitlab/log/ && \
	chmod -R u+rwX gitlab/tmp/ && \
	chmod -R u+rwX gitlab/tmp/pids/ && \
	chmod -R u+rwX gitlab/tmp/sockets/ && \
	chmod -R u+rwX gitlab/public/uploads

RUN mkdir gitlab-satellites && \
	chown -R git gitlab-satellites && \
	chmod u+rwx,g+rx,o-rwx gitlab-satellites

USER git

RUN git config --global user.name "GitLab" && \
	git config --global user.email "gitlab@localhost" && \
	git config --global core.autocrlf input

WORKDIR /home/git/gitlab
RUN bundle install --deployment --without development test postgres aws
RUN bundle exec rake assets:precompile RAILS_ENV=production

WORKDIR /home/git/gitlab-shell
RUN bundle install --deployment
