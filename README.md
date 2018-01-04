# GCS SFTP Server
SFTP Server designed to store data in Google Cloud Storage (GCS) Buckets

This is based upon [atmoz/sftp](https://github.com/atmoz/sftp) project.

# Dockerfile
We need to setup an image (based on atomz/sftp) so that we can mount to Google Cloud Storage. That means just installing [gcsfuse](https://github.com/GoogleCloudPlatform/gcsfuse/tree/master/docs).

Find and build your own image using the `Dockerfile` provided.


# Mounting Buckets
We use gcsfuse `--uid`, `--gid`, and `--only-dir` arguments to mount each SFTP users home directory to a single bucket. Inside the bucket, we create a directory for each user manually. (Not sure if using `--only-dir` will work unless the directory already exists)

Sample Bucket Directory Structure:
```
bucket-name
  - /user1
  - /user2
```

The mounting is done in `etc/sftp.d/mount_user_directories.sh`. When deploying to Kubernetes, this script gets executed as a `postStart` command.

## Access Control for GCS Bucket
We just need to ensure your GKE cluster is created with the OAuth scope https://www.googleapis.com/auth/devstorage.read_write, and everything else will be handled automatically. Alternatively, we can mount a file in Service Account JSON key.

# Setup Instructions
## Dependancies
For testing, you will need to have Minikube and Docker installed.

For deployment, you will need to have the gcloud SDK.

## Configuration
You can configure SFTP user accounts by adjusting what's in `etc/sftp/users.conf` and `etc/sftp.d/mount_user_directories.sh`.

When adding a new user, add a new line into `etc/sftp/users.conf`:
```
username:password:uid:gid:directory
```
Where `uid` is a number (e.g. 1003) and `gid` is a number (e.g. 1003).
And then add a new line into `etc/sftp.d/mount_user_directories.sh` to monunt their `directory` to a GCS bucket:
```
runuser -l partner1 -c \
'export GOOGLE_APPLICATION_CREDENTIALS=/credentials/gcloud-key.json && \
gcsfuse -o nonempty --only-dir username bucket /home/username/ftp'
```
This command will mount the bucket as the given user. It also does some environment variable trickery.

:warning: User passwords are committed to this repo as a demo. Not the best to commit them in practice.

## Production Deployment
To deploy to GKE follow these steps:

### To Do
- [ ] Push docker image to dockerhub
- [ ] Document production deployment instructions

## Development Setup for Testing
Follow these steps to run this locally with `minikube`.

### 1. Start minikube:
```
minikube start
```

### 2. Tell minikube to use local docker images:
```
eval $(minikube docker-env)
```

### 3. Build a local image from the `Dockerfile`:
```
docker build --rm -t mikeghen/kube-sftp .
```

### 4. Setup Secrets and Config Mappings
You'll need to adjust files in `etc` so that it reflects the SFTP users you're planning to use. You'll also need a Service Account as well.

Then, you can run these commands to put these files on the cluster as secrets:
```
kubectl create secret generic users --from-file=users.conf=./etc/sftp/users.conf
kubectl create secret generic sftp-gcloud-key --from-file=gcloud-key.json=./secrets/gcloud-key.json
kubectl create configmap gcs-mounts --from-file=gcs-mounts.sh=./etc/sftp.d/gcs-mounts.sh
```
* **users** - Code for maintaining users credentials for SFTP access
* **sftp-cloud-key** - JSON Key for GCS Service Account
* **gcs-mounts** - Code for mounting GCS bucket

### 5. Deploy the SFTP server to Kubernetes:
```
kubectl apply -f sftp.yaml
```
### 6. Get the test IP and port:
```
minikube service sftp --url
```
This will give you the IP and NodePort port.

:information_source: We use NodePort 30022 for SFTP. 

### 7. Confirm you can SFTP using the usernames and password you setup in `etc/sftp*` with `sftp` utility:
```
$ sftp -P 30022 username@192.168.99.100
username@192.168.99.100's password:
sftp> pwd
/directory
```


# To Do
- [ ] Encrypted passwords in `users.conf`
- [ ] Avoid having to "bake" the `users.conf` and `mount_user_directories.sh`
