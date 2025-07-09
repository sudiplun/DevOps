## Jenkins

Things has to care while set-up jenkins freestyle job.
**HERE MY JENKINS FREESYLE JOB STORY**
_confused_

- got confused which ssh key(jenkins or server) being using to access gitlab
- choosing right plugins

**I have done this with jenkins on local machine & deployment on remote server**

- Add private key that has authorized to access your deployment server
- to run desire command over ssh with jenkins.
- jenkins job is basically run command based on events, right.
- so, add your jenkins webhooks URL: to repo on gitlab, read What is webhook first...
- i was stock at git ssh permission, [repeatedly](https://x.com/sudiplun/status/1934207798214041661) cause i'm bad at debugging haha..!
- What is happening, `git pull` or whatever git command that read default `id_ed25519` key from `~/.ssh` and i'm genius working with own keyName.
