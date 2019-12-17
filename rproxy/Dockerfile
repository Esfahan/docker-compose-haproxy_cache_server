From nginx
COPY conf/rproxy.conf /etc/nginx/conf.d/rproxy.conf
RUN sed -i -e 's/listen       80;/listen       8080;/' /etc/nginx/conf.d/default.conf
ENTRYPOINT /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
