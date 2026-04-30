# 🚀 AWS Scalable Diary App using Terraform

## Project Overview

This project demonstrates how to build a **highly available and scalable application architecture on AWS** using Terraform.

The application is a simple Node.js-based diary app deployed on EC2 instances and exposed via an Application Load Balancer.

---

## Architecture

User → ALB → Target Group → Auto Scaling Group → EC2 Instances

---

## Tech Stack

* AWS EC2
* AWS Application Load Balancer (ALB)
* Auto Scaling Group (ASG)
* Terraform
* Node.js
* Linux (Ubuntu)

---

## Features

* Infrastructure as Code using Terraform
* Auto Scaling (min, desired, max capacity)
* Load balancing across multiple instances
* Health checks via Target Group
* Automated app startup using User Data
* High Availability using Multi-AZ setup

---

## Project Structure

terraform-project/
├── provider.tf
├── main.tf
├── variables.tf
├── outputs.tf

---

## How to Run

### 1. Initialize Terraform

terraform init

### 2. Plan Infrastructure

terraform plan

### 3. Apply Configuration

terraform apply

---

## Access Application

After deployment, Terraform will output the ALB DNS.

Open in browser:
http://<alb-dns>

---

## Key Learnings

* Difference between EC2 and Auto Scaling workflows
* Importance of Security Groups and networking
* ALB to Target Group integration
* Debugging unhealthy targets
* Automating application startup using user data

---

## Future Improvements

* Add Terraform modules
* Integrate CI/CD pipeline (Jenkins / GitHub Actions)
* Use RDS for persistent storage
* Add HTTPS using ACM
* Use Docker for containerization

---

## Author

Sravani Savili

---

## Notes

This project was built as part of hands-on learning for DevOps and Cloud Engineering roles.
