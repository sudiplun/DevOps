setup jenkins pipeline for deploy this project by building docker images on jenkins container then push to dockerhub then deploy on server in docker with help of ansible.
*In-short CI/CD pipeline with jenkins, Docker and Ansible*

**plugins(Required)**
- Ansible plugin
- Docker pipeline
- Docker commons Plugin
- gitlab
- Pipeline

**credentials**
- add server access ssh private key
- gitlab authorized_keys 
- dockerhub credentials for image push
- 
![credential](../images/credentails.png)

**webhooks**

at first add Jenkins URL

![jenkins url](../images/jenkins-url.png)


now on individual jobs Tiggers section, got full webhooks url also need to generate secret key that must add to gitlab

![webhooks](../images/web-hooks.png)

adding webhooks in gitlab settings->Webhooks

![gitlab](../images/gitlab-webhooks.png)

**Pipeline**

add repositories on pipeline

![pipeline](../images/pipeline.png)


#### pipeline overview

![pipeline overview](../images/pipeline-overview.png)


---
don't forgot to check used [gitlab repo](https://gitlab.com/sudiplun/collaboration/-/tree/main?ref_type=heads)
