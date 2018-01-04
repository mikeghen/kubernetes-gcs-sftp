#!/bin/bash
# File mounted as: /etc/sftp.d/mount_user_directories.sh

runuser -l partner1 -c \
'export GOOGLE_APPLICATION_CREDENTIALS=/credentials/gcloud-key.json && \
gcsfuse -o nonempty --only-dir user1 bucket /home/user1/ftp'

runuser -l partner2 -c \
'export GOOGLE_APPLICATION_CREDENTIALS=/credentials/gcloud-key.json && \
gcsfuse -o nonempty --only-dir user2 bucket /home/user2/ftp'
