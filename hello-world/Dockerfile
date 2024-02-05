FROM ruby:3.2.2-alpine AS builder

# ============================================================================================================
# Install system packages
# ============================================================================================================
RUN apk add --no-cache --update \
    build-base \
    gcompat \
    libc6-compat \
    libsass \
    sqlite-dev \
    tzdata

COPY Gemfile* .
RUN bundle install

FROM ruby:3.2.2-alpine AS app
RUN apk add --no-cache --update \
    gcompat \
    libc6-compat \
    libsass \
    tzdata \
    sqlite-dev

# ============================================================================================================
# # Create a dedicated user for running the application
# ============================================================================================================
RUN adduser -D app
ENV APP_HOME /home/app
WORKDIR /home/app

# We copy over the entire gems directory for the builder image, containing the already built artifact
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --chown=app . /home/app

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]