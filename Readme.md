# 🚀 Terraform + Puppet + Nagios Automation Project

This project demonstrates how to automate configuration management and infrastructure monitoring using **Terraform**, **Puppet**, and **Nagios Core**.  
The entire pipeline is designed to eliminate manual configuration steps and deploy fully automated, repeatable infrastructure changes across both Linux and Windows systems.

---

## 📘 Project Summary

The project focuses on achieving:

- Automated deployment of Puppet modules and global manifests  
- Automated enforcement of system configuration on Linux & Windows agents  
- Automated deployment of Nagios monitoring configuration  
- Automatic validation and restart of Puppetserver & Nagios services  
- Zero manual configuration on servers  
- A fully repeatable Infrastructure-as-Code workflow  

Terraform acts as the *orchestrator*, while Puppet enforces configuration state, and Nagios monitors host and service health.

---

## 🧰 Tools & Technologies

- **Terraform** — Infrastructure automation (copies files, runs remote commands)  
- **Puppet Master (Ubuntu)** — Configuration management system  
- **Puppet Agent (Windows/Linux)** — Applies configuration catalogs  
- **Nagios Core** — Real-time monitoring & alerting  
- **SSH** — Remote provisioning via Terraform  

---

## 🏗️ How the System Works

### ✔ 1. Terraform Uploads Config Files
Terraform remotely connects to the Linux server and uploads:

- Puppet module (`init.pp`)
- Global node manifest (`site.pp`)
- Nagios host monitoring config (`windows.cfg`)

It then places them into the correct directories on the Puppet Master and Nagios server.

---

### ✔ 2. Puppet Validates & Applies Configuration
Puppet Master validates all manifests, compiles catalogs, and restarts the Puppetserver.

The Windows or Linux Puppet Agent runs:

puppet agent -t

yaml
Copy code

to apply the assigned class:

- Linux node installs Apache and configures a webpage  
- Windows node creates directories, files, and installs software  

---

### ✔ 3. Terraform Automates Nagios Setup
Terraform places the `windows.cfg` file into the Nagios objects directory and automatically adds the reference to `nagios.cfg`.

Nagios validates the configuration and restarts, making the Windows host visible on the Nagios dashboard with multiple service checks.

---

### ✔ 4. Monitoring Goes Live
Nagios begins monitoring:

- Host availability  
- SSH  
- CPU load  
- Disk usage  
- Logged-in users  

The Windows host appears automatically in the Nagios Web UI—no manual config editing.

---

### ✔ 5. Cleanup on Destroy
Running:

terraform destroy -auto-approve

yaml
Copy code

removes:

- Puppet module  
- Global site.pp  
- Nagios object file  
- Nagios configuration reference  

And restarts both services to return the system to a clean state.

---

## 📁 Project Structure Overview

terraform-puppet-nagios/
│
├── puppet-manifests/
│ ├── init.pp # Puppet module classes for Linux & Windows
│ └── site.pp # Node declarations & class assignments
│
├── nagios/
│ └── windows.cfg # Nagios host & service definitions
│
└── main.tf # Terraform automation file

yaml
Copy code

### **What Each Folder Does**

- **puppet-manifests/**  
  Contains Puppet configuration files that define the desired system state.

- **nagios/**  
  Contains the Nagios configuration file for monitoring the Windows host.

- **main.tf**  
  The heart of the automation—deploys all files, validates config, and restarts services.

---

## 🎯 Final Outcome

This project provides:

- A fully automated configuration pipeline  
- Zero manual editing of Puppet or Nagios servers  
- Reliable and repeatable deployments  
- Real-time monitoring of a Windows host  
- Clean and modular infrastructure automation  

It is an excellent example of modern DevOps practices: **IaC + Configuration Management + Monitoring** working together seamlessly.
