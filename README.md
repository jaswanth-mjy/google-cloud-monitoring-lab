# Google Cloud Monitoring Lab - Automated Setup

This script automates the complete Google Cloud Monitoring lab setup including:
- ✅ VM instance creation with NGINX
- ✅ Metrics scope configuration
- ✅ Monitoring groups creation
- ✅ Uptime checks and testing
- ✅ Custom dashboard with CPU load testing

## Prerequisites

- Access to Google Cloud Console with 3 Qwiklabs projects
- Cloud Shell access

## Quick Start - Run in Cloud Shell

### Step 1: Open Cloud Shell
Click the Cloud Shell icon in the top-right corner of Google Cloud Console

### Step 2: Clone/Upload the Script
```bash
# Option A: If you have the script locally, upload it to Cloud Shell
# Click the 3-dot menu in Cloud Shell > Upload

# Option B: Create the file directly
nano shell.sh
# Paste the content and save (Ctrl+X, Y, Enter)
```

### Step 3: Make Script Executable
```bash
chmod +x shell.sh
```

### Step 4: Run the Script
```bash
./shell.sh
```

## What the Script Does

### Task 1: Configure Resource Projects
- Creates `worker-1-server` in Project 2 (us-central1-b, e2-medium)
- Creates `worker-2-server` in Project 3 (us-central1-b, e2-medium)
- Installs NGINX on both servers
- Configures HTTP firewall rules

### Task 2: Create Metrics Scope
- Adds Worker 1 and Worker 2 projects to Monitoring Project's metrics scope

### Task 3: Create Monitoring Groups
- Creates "Frontend Servers" group (component=frontend)
- Creates "Frontend Dev" subgroup (component=frontend AND stage=dev)
- Applies proper labels to VMs

### Task 4: Create Uptime Check
- Creates HTTP uptime check for Frontend Servers
- Tests failure scenario by stopping worker-1-server
- Demonstrates alerting behavior

### Task 5: Create Custom Dashboard
- Restarts worker-1-server
- Creates "Developer's Frontend" dashboard with:
  - Dev Server Uptime chart
  - CPU Utilization chart
- Generates CPU load using Apache Bench from worker-2-server

## Project Configuration

The script uses the following project IDs (already configured):
- **Project ID 1 (Monitoring):** qwiklabs-gcp-01-8738a17451ea
- **Project ID 2 (Worker 1):** qwiklabs-gcp-02-9402c6127f7c
- **Project ID 3 (Worker 2):** qwiklabs-gcp-01-99d92e72d5c9

## Execution Time

Total execution time: ~10-15 minutes
- VM creation: ~2 minutes
- NGINX installation: ~3 minutes
- Monitoring setup: ~2 minutes
- Load testing: ~5-8 minutes

## Monitoring Links

After execution, the script provides links to:
- Monitoring Dashboard
- VM Instances Dashboard
- Groups Page
- Uptime Checks
- Metrics Explorer
- Logs Explorer
- Custom Dashboard

## Troubleshooting

### Permission Issues
```bash
# Ensure you're authenticated
gcloud auth list

# Set the correct project
gcloud config set project [PROJECT_ID]
```

### Script Won't Execute
```bash
# Make sure it's executable
chmod +x shell.sh

# Check for line ending issues (if uploaded from Windows)
dos2unix shell.sh  # If available
# or
sed -i 's/\r$//' shell.sh
```

### Firewall Already Exists Errors
These are normal and handled by the script with error suppression.

## Manual Verification

After script completion, verify:
1. Both VMs are created and running (except worker-1 after uptime test)
2. NGINX accessible via external IPs
3. Monitoring groups show 2 VM instances
4. Uptime check is created
5. Dashboard displays metrics

## Clean Up

To delete resources after the lab:
```bash
# Delete VMs
gcloud compute instances delete worker-1-server --zone=us-central1-b --project=[PROJECT_ID_2] --quiet
gcloud compute instances delete worker-2-server --zone=us-central1-b --project=[PROJECT_ID_3] --quiet

# Delete firewall rules
gcloud compute firewall-rules delete default-allow-http --project=[PROJECT_ID_2] --quiet
gcloud compute firewall-rules delete default-allow-http --project=[PROJECT_ID_3] --quiet
```

## Support

For issues or questions:
- Check Cloud Shell logs for error messages
- Verify project IDs are correct in the script
- Ensure you have necessary IAM permissions
- Check quota limits in your projects

---

**Note:** This script is designed for Google Cloud Qwiklabs environments and automates manual lab steps for learning purposes.
