#!/bin/bash
# Cloud Shell Upload Instructions

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║     Upload to Google Cloud Shell - Instructions             ║
╚══════════════════════════════════════════════════════════════╝

METHOD 1: Direct Upload (Recommended)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Open Google Cloud Console
2. Click Cloud Shell icon (top-right)
3. In Cloud Shell, click ⋮ (three dots) > Upload
4. Select these files:
   • shell.sh
   • setup.sh
   • README.md

5. After upload, run:
   chmod +x setup.sh shell.sh && ./setup.sh

6. Then run the lab:
   ./shell.sh


METHOD 2: Git Clone (If pushed to GitHub)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Create GitHub repository
2. Push your local commits:
   
   git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git
   git branch -M main
   git push -u origin main

3. In Cloud Shell, run:
   
   git clone https://github.com/YOUR_USERNAME/REPO_NAME.git
   cd REPO_NAME
   chmod +x setup.sh shell.sh
   ./setup.sh
   ./shell.sh


METHOD 3: Manual Copy-Paste
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Open Cloud Shell
2. Create the file:
   
   nano shell.sh

3. Copy content from shell.sh and paste
4. Save: Ctrl+X, Y, Enter
5. Make executable and run:
   
   chmod +x shell.sh
   ./shell.sh


QUICK TEST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
After upload, verify with:

ls -lh shell.sh setup.sh README.md

You should see all three files with proper permissions.


WHAT HAPPENS NEXT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
The script will automatically:
✓ Create 2 VM instances (worker-1, worker-2)
✓ Install NGINX on both
✓ Configure monitoring and metrics scope
✓ Create monitoring groups
✓ Set up uptime checks
✓ Build custom dashboard
✓ Run load tests
⏱️  Total time: ~10-15 minutes

EOF
