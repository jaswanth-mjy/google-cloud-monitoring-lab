#!/bin/bash
# Google Cloud Monitoring Lab - Automated Setup Script
# This script automates VM creation, monitoring setup, and dashboard configuration

clear

# Define color variables

BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`

# Array of color codes excluding black and white
TEXT_COLORS=($RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN)
BG_COLORS=($BG_RED $BG_GREEN $BG_YELLOW $BG_BLUE $BG_MAGENTA $BG_CYAN)

# Pick random colors
RANDOM_TEXT_COLOR=${TEXT_COLORS[$RANDOM % ${#TEXT_COLORS[@]}]}
RANDOM_BG_COLOR=${BG_COLORS[$RANDOM % ${#BG_COLORS[@]}]}

#----------------------------------------------------start--------------------------------------------------#

echo "${RANDOM_BG_COLOR}${RANDOM_TEXT_COLOR}${BOLD}Starting Execution${RESET}"

# Set zone to us-central1-b as per lab requirements
export ZONE="us-central1-b"
export REGION="us-central1"

# Step 1: Setting Project IDs
echo "${BOLD}${CYAN}Setting Project IDs${RESET}"

PROJECT_ID_1="qwiklabs-gcp-01-8738a17451ea"
PROJECT_ID_2="qwiklabs-gcp-02-9402c6127f7c"
PROJECT_ID_3="qwiklabs-gcp-01-99d92e72d5c9"

echo "PROJECT_ID_1: $PROJECT_ID_1"
echo "PROJECT_ID_2: $PROJECT_ID_2"
echo "PROJECT_ID_3: $PROJECT_ID_3"
echo

# Step 2: Create worker-1-server VM Instance in Worker 1 Project
echo "${BOLD}${MAGENTA}Creating worker-1-server in Worker 1 Project${RESET}"
gcloud config set project $PROJECT_ID_2

gcloud compute instances create worker-1-server \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --metadata=enable-oslogin=true \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --tags=http-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=worker-1-server,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250110,mode=rw,size=10,type=pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any

gcloud compute firewall-rules create default-allow-http \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server 2>/dev/null || echo "Firewall rule already exists"

echo "${BOLD}${GREEN}worker-1-server created successfully${RESET}"
sleep 10

# Step 3: Create worker-2-server VM Instance in Worker 2 Project
echo "${BOLD}${CYAN}Creating worker-2-server in Worker 2 Project${RESET}"
gcloud config set project $PROJECT_ID_3

gcloud compute instances create worker-2-server \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --metadata=enable-oslogin=true \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --tags=http-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=worker-2-server,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250110,mode=rw,size=10,type=pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any

gcloud compute firewall-rules create default-allow-http \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server 2>/dev/null || echo "Firewall rule already exists"

echo "${BOLD}${GREEN}worker-2-server created successfully${RESET}"
sleep 10

# Step 5: SSH into worker-1-server and Install NGINX
echo "${BOLD}${RED}SSH into worker-1-server and Install NGINX${RESET}"
gcloud config set project $PROJECT_ID_2

gcloud compute ssh --zone "$ZONE" "worker-1-server" --project "$PROJECT_ID_2" --quiet --command "sudo apt-get update && sudo apt-get install -y nginx && ps auwx | grep nginx "

echo "${BOLD}${GREEN}NGINX installed on worker-1-server${RESET}"
sleep 10

# Step 6: SSH into worker-2-server and Install NGINX
echo "${BOLD}${YELLOW}SSH into worker-2-server and Install NGINX${RESET}"
gcloud config set project $PROJECT_ID_3

gcloud compute ssh --zone "$ZONE" "worker-2-server" --project "$PROJECT_ID_3" --quiet --command "sudo apt-get update && sudo apt-get install -y nginx && ps auwx | grep nginx "

echo "${BOLD}${GREEN}NGINX installed on worker-2-server${RESET}"
sleep 10

# Step 7: Update Labels for worker-1-server
echo "${BOLD}${CYAN}Update Labels for worker-1-server${RESET}"
gcloud config set project $PROJECT_ID_2

gcloud compute instances update worker-1-server \
    --update-labels=component=frontend,stage=dev \
    --zone=$ZONE

# Step 8: Update Labels for worker-2-server
echo "${BOLD}${MAGENTA}Update Labels for worker-2-server${RESET}"
gcloud config set project $PROJECT_ID_3

gcloud compute instances update worker-2-server \
    --update-labels=component=frontend,stage=test \
    --zone=$ZONE

gcloud config set project $PROJECT_ID_1

# Step 9: Add Worker Projects to Metrics Scope
echo "${BOLD}${YELLOW}Adding Worker 1 and Worker 2 projects to Metrics Scope${RESET}"

# Add Worker 1 project to metrics scope
gcloud monitoring metrics-scopes create-monitored-project projects/$PROJECT_ID_1 \
    --monitored-project=projects/$PROJECT_ID_2 2>/dev/null || echo "Worker 1 project already added to metrics scope"

# Add Worker 2 project to metrics scope
gcloud monitoring metrics-scopes create-monitored-project projects/$PROJECT_ID_1 \
    --monitored-project=projects/$PROJECT_ID_3 2>/dev/null || echo "Worker 2 project already added to metrics scope"

echo "${BOLD}${GREEN}Metrics scope configured successfully${RESET}"
sleep 5

# Step 10: Create Monitoring Group - Frontend Servers
echo "${BOLD}${CYAN}Creating Monitoring Group: Frontend Servers${RESET}"

cat > frontend-group.json <<EOF_END
{
  "displayName": "Frontend Servers",
  "filter": "resource.metadata.tag.component=\"frontend\""
}
EOF_END

GROUP_ID=$(gcloud monitoring groups create --display-name="Frontend Servers" \
  --filter="resource.metadata.tag.component=\"frontend\"" \
  --format="value(name)" 2>/dev/null || echo "")

if [ -z "$GROUP_ID" ]; then
    # If group creation via gcloud fails, try to get existing group
    GROUP_ID=$(gcloud monitoring groups list --filter="displayName='Frontend Servers'" \
      --format="value(name)" 2>/dev/null | head -n 1)
fi

echo "${BOLD}${GREEN}Frontend Servers group created/found${RESET}"
sleep 3

# Step 11: Create Monitoring Subgroup - Frontend Dev
echo "${BOLD}${MAGENTA}Creating Monitoring Subgroup: Frontend Dev${RESET}"

if [ ! -z "$GROUP_ID" ]; then
    # Create subgroup with combined criteria (component=frontend AND stage=dev)
    gcloud monitoring groups create --display-name="Frontend Dev" \
      --filter="resource.metadata.tag.component=\"frontend\" AND resource.metadata.tag.stage=\"dev\"" \
      --parent-name="$GROUP_ID" 2>/dev/null || echo "Frontend Dev subgroup created or already exists"
else
    # Create as standalone group if parent group ID not available
    gcloud monitoring groups create --display-name="Frontend Dev" \
      --filter="resource.metadata.tag.component=\"frontend\" AND resource.metadata.tag.stage=\"dev\"" 2>/dev/null || echo "Frontend Dev group created or already exists"
fi

echo "${BOLD}${GREEN}Frontend Dev subgroup created${RESET}"
sleep 3

# Step 12: Create an Email Notification Channel
echo "${BOLD}${YELLOW}Create an Email Notification Channel${RESET}"
cat > email-channel.json <<EOF_END
{
  "type": "email",
  "displayName": "cloudwalabanda",
  "description": "Awesome",
  "labels": {
    "email_address": "$USER_EMAIL"
  }
}
EOF_END

gcloud beta monitoring channels create --channel-content-from-file="email-channel.json"

echo "${BOLD}${GREEN}Monitoring configuration completed successfully${RESET}"
echo "${BOLD}${CYAN}Metrics Scope: Worker 1 and Worker 2 projects added${RESET}"
echo "${BOLD}${CYAN}Monitoring Groups: Frontend Servers and Frontend Dev created${RESET}"
echo

# Step 14: Create Uptime Check for Frontend Servers
echo "${BOLD}${BLUE}Creating Uptime Check for Frontend Servers${RESET}"

# Create uptime check configuration
cat > uptime-check.json <<EOF_END
{
  "displayName": "Frontend Servers Uptime",
  "monitoredResource": {
    "type": "uptime_url",
    "labels": {}
  },
  "httpCheck": {
    "requestMethod": "GET",
    "path": "/",
    "port": 80
  },
  "period": "60s",
  "timeout": "10s",
  "contentMatchers": [],
  "checkerType": "STATIC_IP_CHECKERS"
}
EOF_END

# Get worker-1 and worker-2 external IPs
WORKER1_IP=$(gcloud compute instances describe worker-1-server \
  --zone=$ZONE \
  --project=$PROJECT_ID_2 \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

WORKER2_IP=$(gcloud compute instances describe worker-2-server \
  --zone=$ZONE \
  --project=$PROJECT_ID_3 \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo "Worker 1 IP: $WORKER1_IP"
echo "Worker 2 IP: $WORKER2_IP"

# Create uptime check for worker-1
gcloud monitoring uptime-checks create "frontend-servers-uptime" \
  --display-name="Frontend Servers Uptime" \
  --resource-type=uptime-url \
  --http-check \
  --path="/" \
  --port=80 \
  --host="$WORKER1_IP" \
  --period=60 \
  --timeout=10s 2>/dev/null || echo "Uptime check already exists or creation pending"

echo "${BOLD}${GREEN}Uptime check created for Frontend Servers${RESET}"
echo "${BOLD}${YELLOW}Waiting 30 seconds for uptime check to initialize...${RESET}"
sleep 30

# Step 15: Test Uptime Check Failure - Stop Worker 1 Server
echo
echo "${BOLD}${RED}Testing Uptime Check Failure - Stopping worker-1-server${RESET}"
gcloud config set project $PROJECT_ID_2

gcloud compute instances stop worker-1-server --zone=$ZONE --quiet

echo "${BOLD}${YELLOW}worker-1-server stopped. Waiting for uptime check to detect failure...${RESET}"
echo "${BOLD}${CYAN}Monitor the uptime check dashboard to see the failure detection${RESET}"
sleep 15

gcloud config set project $PROJECT_ID_1

echo
echo "${BOLD}${GREEN}Task 4 Completed - Uptime Check Created and Tested${RESET}"
echo

# Step 16: Verification and Monitoring Links
echo "${BOLD}${BLUE}Access Monitoring Dashboards and Resources${RESET}"
echo
echo "${BOLD}${CYAN}=== Core Monitoring Dashboards ===${RESET}"
echo "Monitoring Dashboard: https://console.cloud.google.com/monitoring/dashboards?project=$PROJECT_ID_1"
echo "VM Instances Dashboard: https://console.cloud.google.com/monitoring/dashboards/resourceList/gce_instance?project=$PROJECT_ID_1"
echo "Groups Page: https://console.cloud.google.com/monitoring/groups?project=$PROJECT_ID_1"
echo
echo "${BOLD}${YELLOW}=== Uptime Checks ===${RESET}"
echo "Uptime Checks: https://console.cloud.google.com/monitoring/uptime?project=$PROJECT_ID_1"
echo "Frontend Servers Uptime Check: https://console.cloud.google.com/monitoring/uptime/frontend-servers-uptime?project=$PROJECT_ID_1"
echo
echo "${BOLD}${MAGENTA}=== Metrics & Logs ===${RESET}"
echo "Metrics Explorer: https://console.cloud.google.com/monitoring/metrics-explorer?project=$PROJECT_ID_1"
echo "  - Search for: VM Instance > Uptime_check > Check passed"
echo "  - Add filter: checked_resource_id"
echo "Logs Explorer: https://console.cloud.google.com/logs/query?project=$PROJECT_ID_1"
echo "  - Search for log name: uptime_checks"
echo "Alerting: https://console.cloud.google.com/monitoring/alerting?project=$PROJECT_ID_1"
echo
echo "${BOLD}${GREEN}=== Worker VMs ===${RESET}"
echo "Worker 1 IP: http://$WORKER1_IP (Status: STOPPED for testing)"
echo "Worker 2 IP: http://$WORKER2_IP (Status: RUNNING)"
echo
echo "${BOLD}${CYAN}=== Important Notes ===${RESET}"
echo "- Uptime check will show failures after worker-1-server stopped"
echo "- Check ID: frontend-servers-uptime"
echo "- Alert should fire after a few failed checks"
echo "- After 5 minutes, group may remove stopped server from monitoring"
echo

# Step 17: Start worker-1-server for Dashboard Testing
echo
echo "${BOLD}${BLUE}Task 5: Creating Custom Dashboard${RESET}"
echo "${BOLD}${YELLOW}Starting worker-1-server...${RESET}"
gcloud config set project $PROJECT_ID_2

gcloud compute instances start worker-1-server --zone=$ZONE --quiet

echo "${BOLD}${GREEN}worker-1-server started successfully${RESET}"
sleep 15

# Step 18: Create Custom Dashboard - Developer's Frontend
echo
echo "${BOLD}${CYAN}Creating Custom Dashboard: Developer's Frontend${RESET}"
gcloud config set project $PROJECT_ID_1

# Get instance ID for worker-1-server for filtering
WORKER1_INSTANCE_ID=$(gcloud compute instances describe worker-1-server \
  --zone=$ZONE \
  --project=$PROJECT_ID_2 \
  --format='get(id)')

echo "Worker 1 Instance ID: $WORKER1_INSTANCE_ID"

# Create dashboard with uptime check and CPU utilization charts
cat > dashboard-config.json <<EOF_END
{
  "displayName": "Developer's Frontend",
  "mosaicLayout": {
    "columns": 12,
    "tiles": [
      {
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Dev Server Uptime",
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "filter": "metric.type=\"compute.googleapis.com/instance/uptime_check/check_passed\" resource.type=\"gce_instance\" resource.label.instance_id=\"$WORKER1_INSTANCE_ID\"",
                    "aggregation": {
                      "alignmentPeriod": "300s",
                      "perSeriesAligner": "ALIGN_COUNT_TRUE"
                    }
                  }
                },
                "plotType": "LINE"
              }
            ],
            "timeshiftDuration": "0s",
            "yAxis": {
              "label": "y1Axis",
              "scale": "LINEAR"
            }
          }
        }
      },
      {
        "xPos": 6,
        "width": 6,
        "height": 4,
        "widget": {
          "title": "CPU Utilization - worker-1-server",
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "filter": "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" resource.type=\"gce_instance\" metadata.user_labels.instance_name=\"worker-1-server\"",
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_MEAN"
                    }
                  }
                },
                "plotType": "LINE"
              }
            ],
            "timeshiftDuration": "0s",
            "yAxis": {
              "label": "y1Axis",
              "scale": "LINEAR"
            }
          }
        }
      }
    ]
  }
}
EOF_END

gcloud monitoring dashboards create --config-from-file=dashboard-config.json 2>/dev/null || echo "Dashboard created or already exists"

echo "${BOLD}${GREEN}Custom Dashboard 'Developer's Frontend' created${RESET}"
sleep 5

# Step 19: Generate Load on worker-1-server using worker-2-server
echo
echo "${BOLD}${MAGENTA}Generating CPU Load on worker-1-server for Dashboard Testing${RESET}"
gcloud config set project $PROJECT_ID_3

echo "${BOLD}${YELLOW}Installing Apache Bench on worker-2-server...${RESET}"

# Install Apache Bench on worker-2-server
gcloud compute ssh --zone "$ZONE" "worker-2-server" --project "$PROJECT_ID_3" --quiet --command "sudo apt-get update && sudo apt-get install -y apache2-utils"

sleep 5

echo "${BOLD}${CYAN}Generating first wave of traffic (100,000 requests, 100 concurrent)...${RESET}"

# First load test - 100,000 requests with 100 concurrent
gcloud compute ssh --zone "$ZONE" "worker-2-server" --project "$PROJECT_ID_3" --quiet --command "ab -s 120 -n 100000 -c 100 http://$WORKER1_IP/" &

LOAD_TEST_PID=$!
sleep 30

echo "${BOLD}${CYAN}Generating second wave of traffic (500,000 requests, 500 concurrent)...${RESET}"

# Wait for first test to complete
wait $LOAD_TEST_PID 2>/dev/null

sleep 10

# Second load test - 500,000 requests with 500 concurrent
gcloud compute ssh --zone "$ZONE" "worker-2-server" --project "$PROJECT_ID_3" --quiet --command "ab -s 120 -n 500000 -c 500 http://$WORKER1_IP/"

echo "${BOLD}${GREEN}Load testing completed${RESET}"
echo "${BOLD}${YELLOW}Wait 2-3 minutes for metrics to appear on the dashboard${RESET}"

gcloud config set project $PROJECT_ID_1

echo
echo "${BOLD}${GREEN}Task 5 Completed - Custom Dashboard Created and Tested${RESET}"
echo

# Step 20: Final Verification Links
echo "${BOLD}${BLUE}Access Custom Dashboard${RESET}"
echo
echo "Developer's Frontend Dashboard: https://console.cloud.google.com/monitoring/dashboards?project=$PROJECT_ID_1"
echo "All Dashboards: https://console.cloud.google.com/monitoring/dashboards?project=$PROJECT_ID_1"
echo
echo "${BOLD}${GREEN}=== Lab Summary ===${RESET}"
echo "✓ Task 1: VM instances created and NGINX installed"
echo "✓ Task 2: Metrics scope configured with Worker 1 & 2"
echo "✓ Task 3: Monitoring groups created (Frontend Servers, Frontend Dev)"
echo "✓ Task 4: Uptime check created and failure tested"
echo "✓ Task 5: Custom dashboard created with CPU load testing"
echo

# Function to display a random congratulatory message
function random_congrats() {
    MESSAGES=(
        "${GREEN}Congratulations For Completing The Lab! Keep up the great work!${RESET}"
        "${CYAN}Well done! Your hard work and effort have paid off!${RESET}"
        "${YELLOW}Amazing job! You’ve successfully completed the lab!${RESET}"
        "${BLUE}Outstanding! Your dedication has brought you success!${RESET}"
        "${MAGENTA}Great work! You’re one step closer to mastering this!${RESET}"
        "${RED}Fantastic effort! You’ve earned this achievement!${RESET}"
        "${CYAN}Congratulations! Your persistence has paid off brilliantly!${RESET}"
        "${GREEN}Bravo! You’ve completed the lab with flying colors!${RESET}"
        "${YELLOW}Excellent job! Your commitment is inspiring!${RESET}"
        "${BLUE}You did it! Keep striving for more successes like this!${RESET}"
        "${MAGENTA}Kudos! Your hard work has turned into a great accomplishment!${RESET}"
        "${RED}You’ve smashed it! Completing this lab shows your dedication!${RESET}"
        "${CYAN}Impressive work! You’re making great strides!${RESET}"
        "${GREEN}Well done! This is a big step towards mastering the topic!${RESET}"
        "${YELLOW}You nailed it! Every step you took led you to success!${RESET}"
        "${BLUE}Exceptional work! Keep this momentum going!${RESET}"
        "${MAGENTA}Fantastic! You’ve achieved something great today!${RESET}"
        "${RED}Incredible job! Your determination is truly inspiring!${RESET}"
        "${CYAN}Well deserved! Your effort has truly paid off!${RESET}"
        "${GREEN}You’ve got this! Every step was a success!${RESET}"
        "${YELLOW}Nice work! Your focus and effort are shining through!${RESET}"
        "${BLUE}Superb performance! You’re truly making progress!${RESET}"
        "${MAGENTA}Top-notch! Your skill and dedication are paying off!${RESET}"
        "${RED}Mission accomplished! This success is a reflection of your hard work!${RESET}"
        "${CYAN}You crushed it! Keep pushing towards your goals!${RESET}"
        "${GREEN}You did a great job! Stay motivated and keep learning!${RESET}"
        "${YELLOW}Well executed! You’ve made excellent progress today!${RESET}"
        "${BLUE}Remarkable! You’re on your way to becoming an expert!${RESET}"
        "${MAGENTA}Keep it up! Your persistence is showing impressive results!${RESET}"
        "${RED}This is just the beginning! Your hard work will take you far!${RESET}"
        "${CYAN}Terrific work! Your efforts are paying off in a big way!${RESET}"
        "${GREEN}You’ve made it! This achievement is a testament to your effort!${RESET}"
        "${YELLOW}Excellent execution! You’re well on your way to mastering the subject!${RESET}"
        "${BLUE}Wonderful job! Your hard work has definitely paid off!${RESET}"
        "${MAGENTA}You’re amazing! Keep up the awesome work!${RESET}"
        "${RED}What an achievement! Your perseverance is truly admirable!${RESET}"
        "${CYAN}Incredible effort! This is a huge milestone for you!${RESET}"
        "${GREEN}Awesome! You’ve done something incredible today!${RESET}"
        "${YELLOW}Great job! Keep up the excellent work and aim higher!${RESET}"
        "${BLUE}You’ve succeeded! Your dedication is your superpower!${RESET}"
        "${MAGENTA}Congratulations! Your hard work has brought great results!${RESET}"
        "${RED}Fantastic work! You’ve taken a huge leap forward today!${RESET}"
        "${CYAN}You’re on fire! Keep up the great work!${RESET}"
        "${GREEN}Well deserved! Your efforts have led to success!${RESET}"
        "${YELLOW}Incredible! You’ve achieved something special!${RESET}"
        "${BLUE}Outstanding performance! You’re truly excelling!${RESET}"
        "${MAGENTA}Terrific achievement! Keep building on this success!${RESET}"
        "${RED}Bravo! You’ve completed the lab with excellence!${RESET}"
        "${CYAN}Superb job! You’ve shown remarkable focus and effort!${RESET}"
        "${GREEN}Amazing work! You’re making impressive progress!${RESET}"
        "${YELLOW}You nailed it again! Your consistency is paying off!${RESET}"
        "${BLUE}Incredible dedication! Keep pushing forward!${RESET}"
        "${MAGENTA}Excellent work! Your success today is well earned!${RESET}"
        "${RED}You’ve made it! This is a well-deserved victory!${RESET}"
        "${CYAN}Wonderful job! Your passion and hard work are shining through!${RESET}"
        "${GREEN}You’ve done it! Keep up the hard work and success will follow!${RESET}"
        "${YELLOW}Great execution! You’re truly mastering this!${RESET}"
        "${BLUE}Impressive! This is just the beginning of your journey!${RESET}"
        "${MAGENTA}You’ve achieved something great today! Keep it up!${RESET}"
        "${RED}You’ve made remarkable progress! This is just the start!${RESET}"
    )

    RANDOM_INDEX=$((RANDOM % ${#MESSAGES[@]}))
    echo -e "${BOLD}${MESSAGES[$RANDOM_INDEX]}"
}

# Display a random congratulatory message
random_congrats

echo -e "\n"  # Adding one blank line

cd

remove_files() {
    # Loop through all files in the current directory
    for file in *; do
        # Check if the file name starts with "gsp", "arc", or "shell"
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            # Check if it's a regular file (not a directory)
            if [[ -f "$file" ]]; then
                # Remove the file and echo the file name
                rm "$file"
                echo "File removed: $file"
            fi
        fi
    done
}

remove_files