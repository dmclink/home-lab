# Home Lab
## Description
Homelab automation for PN50 MiniPC via Tailscale and K3s.

## Initial Setup
1. Put device hostnames/IPs inventory.yml under the listed group names.
  - see inventory.yml.example for group names
  - changing group names requires changing the corresponding name in site.yml
2. Add vars to group_vars/all.yml to select specific hosts to pin infra to 
  - see: group_vars/all.yml.example
3. Add ansible-vault vault.yml in root with postgres password
  - see: vault.yml.example
  - generate a new seed for app passwords with command `openssl rand -base64 48` or similar
4. Total system bootstrap and setup: from root run command
  - ensure user has sudo privileges on all devices
`ansible-playbook site.yml -i inventory.yml -K --ask-vault-password`
5. If inventory.ini format or a different location for the file is preferred, update the inventory path in ansible.cfg and in the bin/deploy-app script
6. create a vault password file at ~/.ansible/vault_pass.txt and chmod 600 on it
  - otherwise if you want to type password every time deploy script won't work and remove vault_password_file from ansible.cfg
  - encrypt vault.yml with this vault_pass.txt file and any project specific vault.yml 

# Dependencies
1. fzf for deploy-app script (soft dependency)
2. yq for db-shell script (soft dependency)

## Usage
- Apps by default are passed the bootstrapped cluster database host address and port
  - can be overwritten by adding app specific overrides in the values.yaml and overwriting the postgres.host or postgres.port variables
  - built string from postgres.host and postgres.port will be stored in environment variable POSTGRES_URL
    - this is modifiable in the common-service Helm chart templates
  - by default the connection string will connec tto the database of the same name as the app unless postgres.db_name variable is set in the app's values.yaml
    - this is also modifiable in the common-service Helm chart templates
- if app needs a connection to the boostrapped database, go into the projects values.yaml and set the postgres.enabled to true
  - auto creates a database user of the same name as app name
- check all pods deployed by this project `kubectl get pods -A -l managed-by=ansible-homelab`
- Adding new hardware run command:
`ansible-playbook site.yml -i inventory.yml -K --ask-vault-password`
- Start developing a new app copy the project from skeletons:
`cp -r skeletons/_cpp apps/my-new-app-name`
  - alternatively run script `new-app` and follow prompts to copy folder and initialize git submodule
- add any dependencies to both stages of the build in the new app's Dockerfile ie. libpqxx-dev / libpqxx-7.7
- link any dependency headers in the CMakeLists.txt file if necessary ie `target_link_libraries(${PROJECT_NAME} PRIVATE pqxx)`
- cd into new project and git init, gh repo create git submodule add
- Adding new app (single deploy) run command from project root:
`ansible-playbook playbooks/deploy_app.yml -i inventory.yml -e app_name=my-new-app-name`
- Alternatively use the deploy-app script from anywhere
- bring up a menu of all apps in /apps/ directory
`deploy-app`
- deploy app directly
`deploy-app my-app-name`
- manually accessing the database can be done with script `db-shell`

Command            | Action on values.yaml | Cluster Pods | Database | Namespace | Local Folder | deploy-all Behavior
---
app deploy         | Sets enabled: true   | Running      | Exists   | Exists    | Exists       | Deploys/Updates
app disable        | Sets enabled: false  | Deleted      | Exists   | Exists    | Exists       | Ignored
app remove         | N/A (Folder Deleted) | Deleted      | Exists   | Exists    | Deleted      | Ignored
app remove --purge | N/A (Folder Deleted) | Deleted      | Deleted  | Deleted   | Deleted      | Ignored
