FROM ubuntu:trusty
MAINTANER Kamil Trzciński <ayufan@ayufan.eu>

RUN apt-get update -y
RUN apt-get install -y sudo build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev logrotate git-core ruby2.0-dev bundler mysql-client libmysqlclient-dev openssh-server

RUN adduser --disabled-login --gecos 'GitLab' git

ADD https://github.com/gitlabhq/gitlabhq/archive/v6.8.1.tar.gz /home/gitgitlab/

WORKDIR /home/git/gitlab
RUN chown -R git log/ && \
	chown -R git tmp/ && \
	chmod -R u+rwX log/ && \
	chmod -R u+rwX tmp/ \
	chmod -R u+rwX tmp/pids/ && \
	chmod -R u+rwX tmp/sockets/ && \
	chmod -R u+rwX public/uploads

RUN mkdir /home/git/gitlab-satellites && \
	chown -R git /home/git/gitlab-satellites && \
	chmod u+rwx,g+rx,o-rwx /home/git/gitlab-satellites

