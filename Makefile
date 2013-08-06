#
# Makefile
# xavier, 2013-07-30 07:56
#
# vim:ft=make

LOGS?=/tmp/make.logs
shell?=bash
SHELL_CONFIG_FILE=${HOME}/.${shell}rc
SERVERDEV_IP?=192.168.0.17
SERVERDEV_PORT?=4242

all: dependencies install

install:
	#TODO Copy in /usr/local/{bin|lib}, but what about templates ? /opt ?
	@echo "[make] Creating local/* directories"
	test -d ${HOME}/local/bin || mkdir -p ${HOME}/local/bin
	test -d ${HOME}/local/lib || mkdir -p ${HOME}/local/lib

	@echo "[make] Copying files"
	cp bin/* ${HOME}/local/bin
	cp lib/* ${HOME}/local/lib

	@echo "[make] Managing ACL"
	chown -R ${USER} ${HOME}/local
	chmod +x ${HOME}/local/bin/*

	@echo "[make] Updating ${SHELL_CONFIG_FILE}"
	echo "export PATH=${PATH}:${HOME}/local/bin:${HOME}/local/lib" >> ${SHELL_CONFIG_FILE}
	echo "export SERVERDEV_IP=${SERVERDEV_IP}" >> ${SHELL_CONFIG_FILE}
	echo "export SERVERDEV_PORT=${SERVERDEV_PORT}" >> ${SHELL_CONFIG_FILE}
	echo "export PYTHONPATH=${PYTHONPATH}:${HOME}/local/lib" >> ${SHELL_CONFIG_FILE}

dependencies:
	@echo "[make] Updating cache..."
	apt-get update 2>&1 >> ${LOGS}
	@echo "[make] Installing packages"
	apt-get -y --force-yes install git python-pip 2>&1 >> ${LOGS}
	@echo "[make] Pip installing python modules"
	pip install --upgrade -r requirements.txt 2>&1 >> ${LOGS}

mysql:
	@echo "Not yet"

team_dashboard:
	@echo "Not yet"

node:
	@echo "Not yet"

R-3.0:
	@echo "Not yet"
