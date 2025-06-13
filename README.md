
# DevSecOps Hands-On Activity Report

## 👨‍💻 Student: Deepak Yadav  
**Date:** 12/06/2025  
**Activity:** Analyzing and Enhancing a CI/CD Pipeline using DevSecOps Best Practices  
**Environment Used:** Docker (instead of Azure VM)

---

## 🔧 Objective

Analyze a sample GitHub Actions CI/CD pipeline for a Node.js application, identify security vulnerabilities, and enhance the pipeline to align with DevSecOps principles. The application was deployed in a **Docker container** rather than an Azure VM.

---

## 🚀 What We Did

### 1. **Pipeline Review**

We began with this GitHub Actions pipeline:

```yaml
name: CI/CD Pipeline for Node.js App
on:
  push:
    branches:
      - main
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3                # Clones the repo
      - uses: actions/setup-node@v3              # Installs Node.js v16
        with:
          node-version: '16'
      - name: Install dependencies
        run: npm install                          # Installs packages from package.json
      - name: Build
        run: npm run build                        # Runs custom build script
      - name: Deploy to server
        env:
          DEPLOY_KEY: 'abc123-super-secret-key'  # Exposes key as env var (insecure!)
        run: scp -r ./build user@server:/var/www/app
```

---

### 2. 🛡️ Identified Security Vulnerabilities

| # | Vulnerability | Description |
|--|----------------|-------------|
| 1 | **Hardcoded secret** | `DEPLOY_KEY` is exposed directly in the pipeline |
| 2 | **No security scanning** | No step checks for vulnerable packages |
| 3 | **No key/host verification** | `scp` runs without any SSH hardening or key management |

---

### 3. 🔐 Security Enhancements

#### ✅ Improved Pipeline (.github/workflows/cicd.yml)

```yaml
name: CI/CD Pipeline for Node.js App
on:
  push:
    branches:
      - master
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '16'
      - name: Install dependencies
        run: npm install

      - name: Run Snyk to check for vulnerabilities
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high

      - name: Build
        run: npm run build

      - name: Deploy to container
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
        run: |
          echo "$DEPLOY_KEY" > deploy_key
          chmod 600 deploy_key
          docker cp ./build <container_name>:/var/www/app
          rm deploy_key
```

---

### 4. 🔍 Dependency Vulnerabilities Found

Using `snyk test`:

```bash
snyk test --severity-threshold=high --file=package.json
```

✅ Detected:  
- `express@4.17.0`  
- `lodash@4.17.11`  
- `minimatch@3.0.4`  






These are known to contain **high-severity vulnerabilities**, as verified by Snyk.

---

### 5. 🐳 Docker Deployment (Instead of Azure VM)

Instead of deploying to a remote VM, we used **Docker** to simulate the target server:

#### Steps:
```bash
# Start a container simulating the target environment
docker run -dit --name devsecops-app -p 3000:3000 node:16 bash

# Copy files into container
docker cp build/ devsecops-app:/var/www/app

# Run the app
docker exec -it devsecops-app bash -c "cd /var/www/app && node index.js"
```

🧪 **Tested via:**  
[http://localhost:3000](http://localhost:3000)  
**Output:** _"Hello, DevSecOps! (Pattern match: true)"_

---


## ✅ Results

| Stage                | Status       |
|---------------------|--------------|
| Install Dependencies| ✅ Success   |
| Snyk Vulnerability Scan | ⚠️ Found Issues |
| Build               | ✅ Success   |
| Docker Deployment   | ✅ Success   |
| Web App Response    | ✅ Working   |

---

## 📌 Summary

This project demonstrated the practical implementation of **DevSecOps** principles in a CI/CD pipeline:

- Replaced hardcoded secrets with **GitHub Secrets**
- Integrated **Snyk** to scan open-source packages
- Used **Docker** for secure local testing and deployment
- Hardened deployment steps (e.g., permissions, key handling)

> ✅ Shift-left security achieved through early vulnerability detection and secure deployment workflows.

---

## 🏁 Final Note

While the original pipeline deployed to an Azure VM, using Docker instead proved effective for testing and deploying the app securely in a containerized environment — aligning with DevSecOps goals.
