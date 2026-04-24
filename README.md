# Home Lab
## Description
Homelab automation for PN50 MiniPC via Tailscale and K3s.

## Initial Setup
1. Put device hostnames/IPs inventory.yml under the listed group names.
  - see inventory.yml.example for group names
  - changing group names requires changing the corresponding name in site.yml
2. Add vars to group_vars/all.yml to select specific hosts to pin infra to 
  - see: group_vars/all.yml.example
3. Add ansible-vault secret_vars.yml in root with postgres password
  - see: secret_vars.yml.example
4. Total system bootstrap and setup: from root run command
  - ensure user has sudo privileges on all devices
`ansible-playbook site.yml -i inventory.yml -K --ask-vault-password`
5. If inventory.ini format or a different location for the file is preferred, update the inventory path in ansible.cfg and in the bin/deploy-app script

# Dependencies
1. fzf for deploy-app script (soft dependency)

## Usage
- Adding new hardware run command:
`ansible-playbook site.yml -i inventory.yml -K --ask-vault-password`
- Start developing a new app copy the project from skeletons:
`cp -r skeletons/_cpp apps/my-new-app-name`
  - cd into new project and git init, gh repo create git submodule add
- Adding new app (single deploy) run command from project root:
`ansible-playbook playbooks/deploy_app.yml -i inventory.yml -e app_name=my-new-app-name`
- Alternatively use the deploy-app script from anywhere
- bring up a menu of all apps in /apps/ directory
`deploy-app`
- deploy app directly
`deploy-app my-app-name`
