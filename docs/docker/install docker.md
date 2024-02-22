# Install Docker
title:: install docker

Install the package on archlinux

```bash
sudo pacman -S docker docker-compose
```

Enable/Start **docker service** on systemd.


```bash
sudo systemctl enable docker. service
sudo systemctl start --now docker.service

```

Create **docker** group.


```bash
sudo groupadd docker
```

Add your user to the **docker** group.


```bash
sudo usermod -aG docker $USER
```

Run the following command or Logout and login again and run (that doesn't work you many need reboot your machine first)

```bash
newgrp docker
```

Check if **docker** can be run without root.

```bash
docker run hello-world
```
-
- [[docker]]