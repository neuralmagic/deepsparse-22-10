# DeepSparse Image Repository for DigitalOcean's 1-Click App

This README highlights the dependencies and flow for building an image on the DigitalOcean marketplace.

[Intro.md](https://github.com/neuralmagic/deepsparse-digitalocean-image/blob/main/Intro.md): is the DigitalOcean README currently found on NM's marketplace profile.  
[template.json](https://github.com/neuralmagic/deepsparse-digitalocean-image/blob/main/template.json): config file for configuring the droplet to build the image, Ubuntu installs/dependencies and which scripts are to be pushed into the image.  
[deepsparse.sh](https://github.com/neuralmagic/deepsparse-digitalocean-image/blob/main/scripts/deepsparse.sh): is the script for installing deepsparse.  
[99-one-click](https://github.com/neuralmagic/deepsparse-digitalocean-image/blob/main/files/etc/update-motd.d/99-one-click): is the script that for populating text when the Droplet boots up.  
90-cleanup.sh](https://github.com/neuralmagic/deepsparse-digitalocean-image/blob/main/scripts/90-cleanup.sh) | [99-img-check.sh](https://github.com/neuralmagic/deepsparse-digitalocean-image/blob/main/scripts/99-img-check.sh): DO scripts used for image check and compliance.

## Installing Packages for App Creation

To install `make` and `Packer` on Ubuntu, you can follow the steps below:

**Installing make:**

1. Open a terminal on your Ubuntu system.

2. Run the following command to install `make`:
   ```bash
   sudo apt update
   sudo apt install make
   ```

**Installing Packer:**

1. Open a terminal on your Ubuntu system.

2. Download the latest version of Packer for Linux by executing the following command:
   ```bash
   wget https://releases.hashicorp.com/packer/<VERSION>/packer_<VERSION>_linux_amd64.zip
   ```

   Replace `<VERSION>` with the specific version number you want to install. You can check for the latest version by visiting the Packer releases page: https://releases.hashicorp.com/packer/

3. Install the unzip utility if it's not already installed:
   ```bash
   sudo apt install unzip
   ```

4. Extract the Packer binary from the downloaded ZIP file:
   ```bash
   unzip packer_<VERSION>_linux_amd64.zip
   ```

5. Move the extracted binary to the `/usr/local/bin/` directory:
   ```bash
   sudo mv packer /usr/local/bin/
   ```

6. Verify that Packer is installed correctly by running the following command:
   ```bash
   packer version
   ```

## Creating a Personal Access Token

To create a DigitalOcean personal access token and set it to the `DIGITALOCEAN_API_TOKEN` environment variable, you can follow these steps:

1. Log in to your DigitalOcean account at https://cloud.digitalocean.com/login.

2. After logging in, click on your account avatar in the top right corner of the control panel and select "API" from the dropdown menu.

3. In the API section, click on the "Generate New Token" button.

4. Enter a name for your token in the "Token Name" field. You can choose any name that helps you identify the purpose of the token.

5. Choose the appropriate permissions based on the tasks you plan to perform. For working with Packer, you will need the "Write" and "Read" permissions for Droplets, Images, and Snapshots.

6. Once you have selected the desired permissions, click on the "Generate Token" button at the bottom of the page.

7. DigitalOcean will generate a new personal access token for you. Make sure to copy the token as it will not be displayed again for security reasons.

8. Open a terminal or command prompt on your local machine.

9. Set the `DIGITALOCEAN_API_TOKEN` environment variable by running the following command:

   ```bash
   export DIGITALOCEAN_API_TOKEN=your-access-token
   ```

10. The `DIGITALOCEAN_API_TOKEN` environment variable is now set, and you can use it in your Packer configuration or any other scripts that interact with the DigitalOcean API.

## Installing Doctl - CLI SDK

This [flow ](https://docs.digitalocean.com/reference/doctl/how-to/install/)installs Doctl for WSL Ubuntu. For Ubuntu not installed on WSL, use this [flow](https://docs.digitalocean.com/reference/doctl/how-to/install/).

Afterwards, connect with DigitalOcean by passing in your Personal Access Token:

```bash
doctl auth init --access-token YOUR_API_TOKEN
```

## Build Automation with Packer

[Packer](https://www.packer.io/intro) is a tool for creating images from a single source configuration. Using this Packer template reduces the entire process of creating, configuring, validating, and snapshotting a build Droplet to a single command:

Install Repo

```bash
git clone https://github.com/neuralmagic/deepsparse-digitalocean-image.git
cd deepsparse-digitalocean-image
```
Initialize DigitalOcean as a builder:

```bash
packer init ./config.pkr.hcl
```
Now build image:

```bash
packer build template.json
```

This command will build an image with DeepSparse, run a few health checks for marketplace integration which are found in the `scripts` directory and save the image as a snapshot onto your DO account.

## Smoke Test

Before starting make sure you have an [SSH key](https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/create-with-openssh/) with your DO account.

**TIP**: to find a list of SSH fingerprints run:

```bash
doctl compute ssh-key list
```

Run the following command to get a list of snapshots in order to obtain the ID of the newly built image:

```bash
doctl compute snapshot list
```
Finally, pass the `Snapshot-ID` of the DeepSparse image and the SSH `fingerprint` into the following command to create a Droplet using a compute optimized instance:

*(FYI the region where the snapshot is saved, needs to be the same as the region where the droplet is created, which in this example was `nyc3`)*

```bash
doctl compute droplet create deepsparse-droplet --image <SNAPSHOT-ID> --region nyc3 --size c-4-intel --ssh-keys <FINGERPRINT>
```

After staging, SSH into Droplet.

**TIP**: To find the IP address of the droplet, run the following commmand:

```bash
doctl compute droplet list
```
Now, pass the IP address into the following command:
```bash
ssh root@<IP-ADDRESS>
```
---

**NLP Benchmark example**:

```bash
deepsparse.benchmark zoo:nlp/question_answering/bert-base/pytorch/huggingface/squad/pruned95_obs_quant-none -i [64,128] -b 64 -nstreams 1 -s sync
```
---

**CV Server example**:

```bash
deepsparse.server \
    task image_classification \
    --model_path "zoo:cv/classification/resnet_v1-50/pytorch/sparseml/imagenet/pruned95-none"
```

After server is up and running pass in our droplet's IP address and default port number (5543) to the URL to check out swagger:

```
http://<IP-ADDRESS@5543/docs
```
---

**NLP Inline Python example**:

open Python in shell:

```bash
python3
```

paste the following code snippet:

```python
from deepsparse import Pipeline

qa_pipeline = Pipeline.create(task="question-answering")
inference = qa_pipeline(question="What's my name?", context="My name is Snorlax")
print(inference)
```
---

**CV Inline Python example**:

Get an example image:

```bash
wget -O basilica.jpg https://raw.githubusercontent.com/neuralmagic/deepsparse/main/src/deepsparse/yolo/sample_images/basilica.jpg
```

Run inference:

```python
from deepsparse import Pipeline

model_path = "zoo:cv/detection/yolov8-s/pytorch/ultralytics/coco/pruned50_quant-none" 
images = ["basilica.jpg"]
yolo_pipeline = Pipeline.create(
    task="yolov8",
    model_path=model_path,
)
pipeline_outputs = yolo_pipeline(images=images)
print(pipeline_outputs)
```