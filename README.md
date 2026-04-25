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
- Adding new hardware run command:
`ansible-playbook site.yml -i inventory.yml -K --ask-vault-password`
- Start developing a new app copy the project from skeletons:
`cp -r skeletons/_cpp apps/my-new-app-name`
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
- apps by default are passed the bootstrapped cluster database host address and port
  - can be overwritten by adding a app specific var and overwriting the db_host or db_port variables with desired 
  - built string from db_host and db_port will be stored in environment variable DATABASE_URL
    - this is modifiable in k8s.yml.j2 template
  - by default the connection string will connect to the database of the same name as the app unless db_name variable is set in project
    - this is also modifiable in k8s.yml.j2 template
- if app needs a connection to the bootstrapped database, go into the app_vars.yml and set needs_db to true 
  - auto creates a database user of the same name as app name
- manually accessing the database can be done with script `db-shell`
