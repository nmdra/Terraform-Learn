### **1. Install Terraform**
- **Download and install Terraform** from [Terraform's official website](https://www.terraform.io/downloads).
- Ensure Terraform is available in your system's PATH by running:

  ```bash
  terraform --version
  ```

---

### **2. Set Up DigitalOcean Account**
- Create an account at [DigitalOcean](https://www.digitalocean.com/) if you don’t have one.
- Generate a **Personal Access Token** from the [API Tokens page](https://cloud.digitalocean.com/account/api/tokens).

---

### **3. Prepare SSH Key**
- Generate an SSH key if you don’t already have one:

  ```bash
  ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/terra
  ```
  - Replace `~/.ssh/terra` with the path you have specified in the `pvt_key` variable.
- Add the public key to DigitalOcean via the [SSH Keys page](https://cloud.digitalocean.com/account/keys).

---

### **4. Configure Variables**
- Create a `terraform.tfvars` file in the same directory as your `.tf` files and set the sensitive variables (optional but recommended):

  ```hcl
  digitalocean_api_token = "your_api_token"
  ```

- Alternatively, you can set variables interactively when prompted or pass them as flags during execution.

---

### **5. Initialize Terraform**
Run the following command to download the necessary providers and initialize Terraform:

```bash
terraform init
```

---

### **6. Plan the Infrastructure**
Run a plan command to preview the changes Terraform will make:

```bash
terraform plan
```

- Review the output to ensure the configuration looks correct.

---

### **7. Apply the Configuration**
Run the apply command to create the resources:

```bash
terraform apply
```

- You will be prompted to confirm. Type `yes` to proceed.

---

### **8. Access Droplet Information**
- Once the configuration is applied successfully, you’ll see the droplet details in the output.
- You can SSH into your droplet using the provided private key:

  ```bash
  ssh -i ~/.ssh/terra root@<droplet_ip>
  ```

  Replace `~/.ssh/terra` and `<droplet_ip>` with the appropriate paths and IP address from the output.

---

### **9. Manage Your Terraform Resources**
- To **view the current state** of your infrastructure:

  ```bash
  terraform show
  ```

- To **destroy the resources** when no longer needed:

  ```bash
  terraform destroy
  ```

---

### Troubleshooting
- If you encounter SSH connection issues, ensure that:
  1. Your SSH key was uploaded to DigitalOcean.
  2. The `pvt_key` path is correct.
  3. Your firewall allows SSH (port 22).

This setup automates creating droplets and configuring them with your specified settings.