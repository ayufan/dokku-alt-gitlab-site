FROM ubuntu:trusty
MAINTAINER Kamil Trzciński <ayufan@ayufan.eu>

RUN apt-get update -y
RUN apt-get install -y sudo build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev logrotate git-core ruby2.0-dev bundler mysql-client libmysqlclient-dev openssh-server ca-certificates supervisor

RUN adduser --disabled-login --gecos 'GitLab' git

USER git
WORKDIR /home/git
ENV HOME /home/git

RUN git clone https://github.com/gitlabhq/gitlabhq.git gitlab -b v6.9.0 --depth=1
RUN git clone https://github.com/gitlabhq/gitlab-shell.git gitlab-shell -b v1.9.3 --depth=1

RUN chmod -R u+rwX gitlab/log/ && \
	chmod -R u+rwX gitlab/tmp/ && \
	chmod -R u+rwX gitlab/tmp/pids/ && \
	chmod -R u+rwX gitlab/tmp/sockets/ && \
	chmod -R u+rwX gitlab/public/uploads

RUN mkdir gitlab-satellites && \
	chmod u+rwx,g+rx,o-rwx gitlab-satellites

RUN git config --global user.name "GitLab" && \
	git config --global user.email "gitlab@ayufan.eu" && \
	git config --global core.autocrlf input

WORKDIR /home/git/gitlab-shell
RUN bundle install --deployment

WORKDIR /home/git/gitlab
RUN bundle install --deployment --without development test postgres aws

# add configs at the end
USER root

ADD gitlab/ /home/git/gitlab/config/
ADD gitlab-shell/config.yml /home/git/gitlab-shell/config.yml
ADD start /start

RUN mkdir -p /var/run/sshd && sed '/pam_loginuid.so/s/^/#/g' -i  /etc/pam.d/*

# Start everything
EXPOSE 22 8080
ENTRYPOINT ["/start"]
