#
# Makefile
# xavier, 2013-07-30 07:56
#
# vim:ft=make

LOGS?=/tmp/make.logs
USER_SHELL?=zsh
SHELL_CONFIG_FILE=${HOME}/.${USER_SHELL}rc
SERVERDEV_IP?=192.168.0.17
SERVERDEV_PORT?=4243

config:
	@echo "Logs path: ${LOGS}"
	#@echo "Shell: $(shell echo ${SHELL})"  
	@echo "Shell: $(USER_SHELL)"  
	@echo "Config file: $(HOME).$(shell)rc"
	@echo "Server ip: $(SERVERDEV_IP)"
	@echo "Server port: $(SERVERDEV_PORT)"

all: config dependencies install
	@echo "Done."

install:
	@echo "[make] Copying files"
	cp bin/* /usr/local/bin
	cp lib/* /usr/local/lib

	#TODO Delete existing old lines in .*rc
	@echo "[make] Updating ${SHELL_CONFIG_FILE}"
	echo "export SERVERDEV_IP=${SERVERDEV_IP}" >> ${SHELL_CONFIG_FILE}
	echo "export SERVERDEV_PORT=${SERVERDEV_PORT}" >> ${SHELL_CONFIG_FILE}
	echo "export PYTHONPATH=${PYTHONPATH}:/usr/local/lib" >> ${SHELL_CONFIG_FILE}

	chmod ugo+x /usr/local/bin/*

dependencies:
	@echo "[make] Updating cache..."
	apt-get update 2>&1 >> ${LOGS}
	@echo "[make] Installing packages: git, pip and redis-server"
	apt-get -y --force-yes install git python-pip redis-server 2>&1 >> ${LOGS}
	@echo "[make] Pip installing python modules"
	pip install --upgrade distribute 2>&1 >> ${LOGS}
	pip install --upgrade -r requirements.txt 2>&1 >> ${LOGS}

check-client:
	pgrep --count hivy > /dev/null || hivy -n master -d node --verbose &
	#TODO Ignore dependencies
	nosetests --verbose --with-progressive --with-coverage --cover-erase --cover-package=hivy-client hivy-client
	coverage report
	killall hivy
