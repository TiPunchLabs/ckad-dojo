# Q12 - Dockerfile with ARG
# Task: Add ARG for APP_VERSION and use it in the image
FROM nginx:1.21

# TODO: Add ARG APP_VERSION=1.0.0
# TODO: Add LABEL version=${APP_VERSION}

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
