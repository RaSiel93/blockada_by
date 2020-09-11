FROM nginx:stable

ARG WORKERS=auto

COPY docker/nginx/nginx.conf /etc/nginx/conf.d/default.conf

RUN sed -i -- "s/worker_processes  1;/worker_processes  ${WORKERS};/g" /etc/nginx/nginx.conf
