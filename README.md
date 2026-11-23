# Terraform for Azure - Hands-On Labs

This repository contains a comprehensive set of hands-on labs for deploying Microsoft Azure infrastructure using **Terraform** (Infrastructure as Code). These labs are designed to help IT professionals transition from manual portal deployments to automated, codified environments.

## 📌 Prerequisites
- An active Microsoft Azure Subscription.
- Azure CLI installed and configured.
- Terraform installed (v1.0+ recommended).
- (Optional) A Linux environment (tested on Rocky Linux) or Windows/Linux terminal.

## 📂 Repository Structure

- **`Lab1/`** - Create a basic Azure Resource Group.
- **`Lab2/`** - Deploy a Virtual Network, Subnet, Public IP, and a single Linux Virtual Machine.
- **`Lab3/`** - Deploy 5 Linux VMs using Terraform `count`, configure NSG rules, and inject Apache web server via `cloud-init`.
- **`Lab4/`** - Deploy 5 Debian VMs with Apache and configure an Azure Load Balancer to distribute HTTP traffic.

## 🚀 How to Use
1. Navigate to the specific lab folder:
   ```bash
   cd Lab1
Initialize Terraform to download the Azure provider:

bash
terraform init
Review the execution plan:

bash
terraform plan -out=terraform-plan.out
Apply the configuration to deploy resources to Azure:

bash
terraform apply "terraform-plan.out"
👨‍💻 Author
Ahmed Abdelwahed - Cloud & Systems Specialist | Microsoft Certified Trainer (MCT)

Blog: www.abdelwahed.me

LinkedIn: https://www.linkedin.com/in/ahmedmct/
