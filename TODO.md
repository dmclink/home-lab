# CLI stuff:
- add commands like status to check the config file flags and app orphans to list databases users in postgres that no longer have a matching folder
- orphans check should iterate through namespaces and look for apps that i dont hvae folders for but are deployed on k3s
- db-orphans to check for databases that i have no folders or no namespces
- cleanup task that compares active namespaces/labels on the cluster against local /apps folder
- prune command to podman image prune on laptop and registry
- app enable that doesn't deploy?
- app deploy -a --all flag?
- `app nats list` `app nats view` as shortcuts for these long comands 
    - ie. `kubectl exec -n nats -it deployment/nats-box -- nats stream ....` `list` `view` `info STREAM_NAME` `get STREAM_NAME`
- `app remove` doesn't have auto complete names

# Features:
- change the build/deploy process for apps to allow for consumers written in app's directory
    - make a proteced consumer/ subdir in apps that the build process sees and deploys on control node
    - allows us to reuse data structures etc. that are tightly coupled to the app
    - probably need a new values object like consumer.enabled=true consumer.systemd.enabled=true or similar to control whether it looks for consumer subdir and how it deploys on control node
    - deploy to quadlet on the control node
    - has a components in values.yaml that it loops through to deploy each component inside
        - otherwise deploys values as a flat file single component
- separate consumers directory optional for generic consumers on control node not tied to any specific app, ie. logging + health
- cronjob no way to set schedule manually?

# Chores:
- update README to include info on how to add new workload types, ie. add directory to charts and name matching files with chart subdir name and add to array in deploy_app_tasks
- add infra namespaces and service names ie. postgres and nats to group_vars/all.yml to they can be configured 
    - lets them be defined in one place and env vars like NATS_URL can be built instead of repeated in every workloadType template
- reorgniaze whole project with roles for readability ref: guidelines here https://redhat-cop.github.io/automation-good-practices/#_introduction
