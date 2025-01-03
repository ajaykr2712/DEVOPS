# Assignment Solutions Explained

## Solution 1: Kubernetes Deployment
### Steps:
1. **Define the API Version**:
   - Use  for Deployment objects.
2. **Set Metadata**:
   - Name the deployment .
3. **Specify the Spec Section**:
   - Define  for three instances.
   - Use  as the container image.
   - Expose port 80 via .

---

## Solution 2: Ansible Playbook
### Steps:
1. **Define the Playbook Name**:
   - Use  for clarity.
2. **Set Hosts**:
   - Apply the tasks to all hosts in the inventory.
3. **Install Apache**:
   - Use the  module to ensure Apache is installed.
4. **Start and Enable Apache**:
   - Use the  module to manage the service state.

---

## Solution 3: GitHub Actions Workflow
### Steps:
1. **Define the Workflow Name**:
   - Name it  for clarity.
2. **Set the Trigger**:
   - Run on  events targeting the  branch.
3. **Define Jobs**:
   - Use  to specify the runner.
   - Include steps for:
     - Checking out code.
     - Setting up Node.js 16.
     - Installing dependencies.
     - Running tests.

