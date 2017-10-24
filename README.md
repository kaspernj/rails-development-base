# rails-development-base

A Docker image for developing Rails applications inside a Docker container for security.


## Concept

When developing multiple applications as a developer, you are exposed to the code of a lot of other developers. You don't know what the code from various libraries are actually doing.

For this reason it makes sense to develop your project inside a sandbox. In this case that sandbox is a Docker container.

By using a combination of Docker, SSH, SSHFS, XQuartz, Gitg and Regexxer this can be done.


## Build the image

```bash
sh build.sh
```


## Install

First customize your setup by copying the run script:
```bash
cp run.sh run-my-project.sh
```

Set up the authorized keys file for SSH access:
```bash
cp shared/ssh/authorized_keys.example shared/ssh/authorized_keys
nano shared/ssh/authorized_keys
```

It is advised not to set up any port forwarding other than SSH, and then forward the ports to your local machine for extra security.


## Mount your project on your local machine

First install SSHFS
```bash
brew install sshfs
```

Then mount your project:
```
sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,port=1022 dev@container.dev:/home/dev/project /Users/username/Dev/project
```

You shoud now be able to open that folder with Sublime or any other editor like normally.


## SSH

Connect to the server and forward the default Rails development port

```bash
ssh ip-of-server -l dev -X -L 3000:localhost:3000
```


## Rails

Clone your project and boot it up as you would normally have done:

```bash
git clone git://project.git
cd project
bundle
rails s -b 0.0.0.0 -p 3000
```


## Git tool

You can use `gitg` for committing individual lines instead of the Github app, which people normally use on OSX. On OSX you should have XQuartz installed and connect to ssh with the `-X` flag in order to forward the graphical applications of the container to your machine.

```bash
ssh ip-of-server -l dev -X
cd project
gitg
```


## Searching for contents in files

You can use Regexxer as an alternative to searching in your editor, since that will be slow over a SSHFS mount. Again you need XQuartz and the `-X` flag for SSH and forwarded graphical applications.

```bash
ssh ip-of-server -l dev -X
cd project
regexxer
```

