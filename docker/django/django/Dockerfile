FROM ubuntu:latest

RUN apt-get -y update && apt-get -y upgrade && apt-get -y install curl python3 iproute2 python python-pip python-dev libmysqlclient-dev vim iputils-ping net-tools mysql-client

EXPOSE 8000

ADD ./requirements.txt /root/
WORKDIR /root

RUN pip install --upgrade pip setuptools
RUN pip install -r requirements.txt

COPY mysite.ini /root
COPY ./.vimrc /root/.vimrc

RUN django-admin startproject mysite

COPY ./settings.py /root/mysite/mysite/settings.py
COPY ./entrypoint.sh /root/entrypoint.sh

RUN chmod +x /root/entrypoint.sh
RUN /root/entrypoint.sh
