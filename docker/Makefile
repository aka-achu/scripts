# Usage:
# make        # install docker engine, docker cli and compose
# make clean  # removing docker from the system

all:
		sudo apt update

		sudo apt-get install -y \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg-agent \
		software-properties-common

		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

		sudo apt-key fingerprint 0EBFCD88

		sudo add-apt-repository \
		"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(shell lsb_release -cs) stable"

		sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose

clean:
		sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-compose

		sudo rm -rf /var/lib/docker