---
- name: "Remove any older, conflicting docker packages."
  apt:
    name: "{{ item }}"
    state: absent

  with_items:
    - docker
    - docker-engine
    - docker.io
    - containerd
    - runc


- name: "Install Docker's dependencies."
  apt:
    name: "{{ item }}"
    state: latest
    update_cache: yes

  with_items:
    - apt-transport-https
    - ca-certificates
    - curl
    - gnupg-agent
    - software-properties-common
    - python-pip
    - python3
    - python3-pip

- name: "Get the docker GPG key."
  apt_key:
    url: https://download.docker.com/linux/ubuntu/gpg
    state: present

- name: "Add our docker packages to the APT repository."
  apt_repository:
    repo: deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ ansible_lsb.codename|lower }} stable

- name: "Install Docker."
  apt:
    name: "{{ item }}"
    state: present
    update_cache: yes

  with_items:
    - docker-ce
    - docker-ce-cli
    - containerd.io

- name: "Install the Python Docker module."
  pip:
    name: docker
    state: present

- name: "Adding the ansible user to the docker linux group..."
  user:
    name: "{{ ansible_user }}"
    group: docker

- name: "Ensure that the docker service is enabled on boot."
  service:
    name: docker
    enabled: yes
    state: started

- name: "Create the docker group."
  group:
    name: docker
    state: present

- name: "Add the ansible host user to the docker group."
  user:
    append: yes  # Ensures that we don't remove from any other group.
    name: "{{ ansible_user }}"
    group: docker

- name: "Prune any old docker resources."
  docker_prune:
    containers: yes
    images: yes
    networks: yes
    volumes: yes
    builder_cache: yes
...
