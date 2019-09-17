install:
	brew install ansible

ad-hoc:
	ansible -i hosts -m command -a "ls" sites

run:
	ansible-playbook -i hosts site.yml

.PHONY: install run
