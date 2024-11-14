---
hide:
  - toc
---

# Compliance Tests

This repository provides a [Chef InSpec](https://docs.chef.io/inspec) profile designed to verify the installation of required packages, binaries, and software, ensuring that they are present and correctly installed. The profile checks for essential components, including package installations, the existence and permissions of binaries, and verifies the proper structure of the filesystem. Additionally, it ensures that utility scripts and configurations needed for Minikube are in place as expected.

On top of that, the [dev-sec/linux-baseline](https://github.com/dev-sec/linux-baseline) is executed as well to check the security of the system. For your Ubuntu system to comply with the Linux Baseline, you can run the hardening script from this repository.

```bash
sudo curl -fsSL https://raw.githubusercontent.com/sommerfeld-io/vm-ubuntu/refs/heads/main/components/provision/hardening.sh | bash -
```

The InSpec binary is installed from the bootstrap script.

Invoke the test suite by cloning the repository and running `components/test-compliance/run.sh`.
