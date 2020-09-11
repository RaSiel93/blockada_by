FROM postgres:latest

RUN apt-get update
RUN apt-get install -y locales locales-all
RUN localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.utf8
ENV LANG ru_RU.utf8
