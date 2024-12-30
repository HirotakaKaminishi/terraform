FROM node:16-alpine

WORKDIR /app

# Install nginx
RUN apk add --no-cache nginx
RUN mkdir -p /run/nginx

# Install application dependencies
COPY package.json ./
RUN npm install

# Copy application files
COPY server.js ./
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html ./

# Create symlink from /app to nginx html directory
RUN ln -sf /app /usr/share/nginx/html

# Start script
RUN echo "#!/bin/sh" > /start.sh && \
    echo "nginx -g 'daemon off;' & " >> /start.sh && \
    echo "node server.js" >> /start.sh && \
    chmod +x /start.sh

RUN apk add --no-cache openssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=JP/ST=Tokyo/L=Tokyo/O=Test/CN=localhost"

EXPOSE 80

CMD ["/start.sh"]