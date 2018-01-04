FROM atmoz/sftp
MAINTAINER Michael Ghen <mike@mikeghen.com>

# Install FUSE so we can mount GCS buckets
# Ref: https://github.com/GoogleCloudPlatform/gcsfuse/blob/master/docs/installing.md
RUN apt-get update
RUN apt-get install -y curl lsb gnupg wget
RUN echo "deb http://packages.cloud.google.com/apt gcsfuse-stretch main" | tee /etc/apt/sources.list.d/gcsfuse.list
RUN cat /etc/apt/sources.list.d/gcsfuse.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update
RUN apt-get install -y gcsfuse
