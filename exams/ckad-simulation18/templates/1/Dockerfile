FROM nginx:1.21

RUN echo "Hello World" > /usr/share/nginx/html/index.html

# TODO: Add instruction to create user 'izanagi' with UID 1000 and switch to it

CMD ["nginx", "-g", "daemon off;"]
