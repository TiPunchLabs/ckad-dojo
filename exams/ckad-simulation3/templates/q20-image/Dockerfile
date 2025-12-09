FROM alpine:3.18

# Application metadata
LABEL maintainer="olympus-team@example.com"
LABEL description="Olympus Application"

# Install dependencies
RUN apk add --no-cache bash

# Copy application
COPY app.sh /app.sh
RUN chmod +x /app.sh

# TODO: Add ENV APP_VERSION=3.0.0 here

# Run application
CMD ["/app.sh"]
