**README for internal purposes only during testing prior to publishing.**

# Questions for Michael:

1. what version of deepsparse should we use? 1.4.2 like GCP marketplace?

## Installing Packages for App Creation

To install `make` and `Packer` on Ubuntu, you can follow the steps below:

**Installing make:**

1. Open a terminal on your Ubuntu system.

2. Run the following command to install `make`:
   ```bash
   sudo apt update
   sudo apt install make
   ```

3. The `make` package will be installed on your system.

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

## Build Automation with Packer

[Packer](https://www.packer.io/intro) is a tool for creating images from a single source configuration. Using this Packer template reduces the entire process of creating, configuring, validating, and snapshotting a build Droplet to a single command:

```
packer build template.json
```