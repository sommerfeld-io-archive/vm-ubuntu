# Ubuntu Virtual Machine

[doc-website]: https://sommerfeld-io.github.io/vm-ubuntu
[github-repo]: https://github.com/sommerfeld-io/vm-ubuntu
[file-issues]: https://github.com/sommerfeld-io/vm-ubuntu/issues
[project-board]: https://github.com/orgs/sommerfeld-io/projects/1/views/1?sliceBy%5Bvalue%5D=sommerfeld-io%2Fvm-ubuntu

This project is a collection of scripts and configuration files to setup a Ubuntu Desktop VM.

- [Documentation Website][doc-website] with instructions about Portainer, Minikube, and more
- [Github Repository][github-repo]
- [Where to file issues][file-issues]
- [Project Board for Issues and Pull Requests][project-board]

## Requirements and Features

Automated and fully reproducible setup of a Ubuntu Desktop VM making the virtual machine ready for development. By doing this, the virtual machine becomes disposable and can be recreated at any time.

```kroki-ditaa no-separation=true
    +----------------+
    |  bootstrap.sh  |
    +---------+------+
              :
              +--------------+
              |              |
+-------------|--------------|-------------------+
|  VM         |              |                   |
|             v              v                   |
|    +--------+-------+    +----+-----------+    |
|    |  apt packages  |    |  Portainer     |    |
|    +----------------+    +----------------+    |
|    |  Docker        |    |  minikube      |    |
|    +----------------+    +----------------+    |
|    |  ...           |    |  ...           |    |
|    +----------------+    +----------------+    |
|                                                |
+------------------------------------------------+
```

The VM represents a sandbox and development environment for Kubernetes-related tasks, proof-of-concepts and experiments. The bootstrap script installs Docker and minikube (among other tools).

## Provisioning

The provisioning is done by a bootstrap script. The script installs all needed packages and configures the VM. However, some manual steps after running the script might still remain.

A prerequisite is that the VM has internet access and `curl` installed.

- Run Bootstrap script:

    ```bash
    sudo curl -fsSL https://raw.githubusercontent.com/sommerfeld-io/vm-ubuntu/refs/heads/main/components/provision/bootstrap.sh | bash -
    ```

- Git might still need some configuration - e.g. `git config --global user.email sebastian@sommerfeld.io` and `git config --global user.name sebastian`.
- d.+: Configure public key on GitHub to allow cloning repositories, pulling and pushing via ssh.
- Maybe you still need to add your user from inside the VM to the docker group

    ```bash
    sudo usermod -aG docker "$USER"
    ```

## Run locally with Vagrant

To test the provisioning scripts locally, you can use Vagrant. The `Vagrantfile` is already included in this repository. To start/stop the Vagrantbox, simply use the `vagrant.sh` script from the root of this repository (next to the `Vagrantfile`). The `bootstrap.sh` script is used to provision the Vagrantbox.

- Maybe you still need to add the `vagrant` user to the docker group (first connect to the Vagrantbox using `vagrant ssh`)

    ```bash
    sudo usermod -aG docker "$USER"
    ```

## Contact

Feel free to contact me via <sebastian@sommerfeld.io> or [raise an issue in this repository][file-issues].
