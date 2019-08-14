#!/bin/bash
# File mounted as: /etc/sftp.d/mount_user_directories.sh
chmod 666 /dev/fuse

runuser -l user1 -c \
'export GOOGLE_APPLICATION_CREDENTIALS=/credentials/gcloud-key.json && \
gcsfuse -o nonempty --only-dir user1 bucket /home/user1/ftp'

runuser -l user2 -c \
'export GOOGLE_APPLICATION_CREDENTIALS=/credentials/gcloud-key.json && \
gcsfuse -o nonempty --only-dir user2 bucket /home/user2/ftp'
