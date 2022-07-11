## Your project adaptation, otherwise comment the line
PROJECT_URL = git@github.jpl.nasa.gov:SunRISE-Ops/SunRISE-AIT.git
MINICONDA_URL = https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
AIT_CORE_URL = git@github.com:Mejiro-McQueen/AIT-Core.git 
AIT_GUI_URL =  git@github.com:Mejiro-McQueen/AIT-GUI.git 
AIT_DSN_URL =  git@github.com:Mejiro-McQueen/AIT-DSN.git 


## Choose a branch for each component 
AIT_CORE_BRANCH := master
AIT_GUI_BRANCH := master
AIT_DSN_BRANCH := master
PROJECT_BRANCH := develop

## Choose config file
CONFIG ?= config.yaml

## Attempt to switch branches after first clone
## Useful for development
BRANCH_SWITCH = False

## Python version must be compatible between componenets
PYTHON_VERSION = 3.8

## Useful Options for Debugging AIT
# DEV=true
# TOX=true

KMC_CLIENT := /ammos/kmc-crypto-client/lib/python$(PYTHON_VERSION)/site-packages
#!----- End of User Configuration -----!#

LD_PRELOAD := /usr/lib64/libcrypto.so.1.1

## Useful for debugging makefile
#.SHELLFLAGS = -vc

PATH := $(HOME)/miniconda3/bin:$(PATH)
SHELL := env PATH=$(PATH) /usr/bin/env bash
PYTHONPATH := $(KMC_CLIENT):$(PYTHONPATH)

AWS = $(findstring ec2, $(shell cat /sys/hypervisor/uuid))

CONDA_ACTIVATE = source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate \
		; conda activate $(project_name) &> /dev/null


ifdef PROJECT_URL
	project_name := $(shell basename $(PROJECT_URL) .git)
else
	project_name = "AIT-Core"
endif

ifdef TEST
	project_name = "AIT-Core"
endif

AIT_CONFIG := ./$(project_name)/config/$(CONFIG)

#--------- Important Targets -------------#
server: virtual-env
	$(CONDA_ACTIVATE)&& \
	ait-server&

shell: virtual-env AIT-Core
	$(CONDA_ACTIVATE)&& \
	bash

nofork: virtual-env AIT-Core AIT-Project
	$(CONDA_ACTIVATE)&& \
	traceback-with-variables ait-server

sadb-auth:
	$(MAKE) -C ./sql_scripts auth-db

sadb-enc:
	$(MAKE) -C ./sql_scripts enc-db

sadb-clean:
	$(MAKE) -C ./sql_scripts clean

clean: 
	pkill ait-server || true
	conda env remove --name $(project_name) &> /dev/null || true 
	conda env remove --name AIT-Core &> /dev/null || true

#--------- AUX TARGETS -------------#
AIT-Project: virtual-env AIT-DSN AIT-GUI AIT-Core
ifdef PROJECT_URL
	 test ! -d $(project_name) && git clone -q --branch $(PROJECT_BRANCH) $(PROJECT_URL) || true

ifeq ($(BRANCH_SWITCH), True)
	 cd $(project_name) && git checkout $(PROJECT_BRANCH)
endif

	 $(CONDA_ACTIVATE) && pip install -q -q ./$(project_name)
endif


AIT-Core: virtual-env
	 test ! -d $@ && git clone -q --branch $(AIT_CORE_BRANCH) $(AIT_CORE_URL) || true

ifeq ($(BRANCH_SWITCH), True)
	 cd $@ && git checkout $(AIT_CORE_BRANCH)
endif

ifndef DEV
	 $(CONDA_ACTIVATE) && pip install -q -q ./$@
endif

ifdef TEST
	$(CONDA_ACTIVATE) && \
	pytest -v -s -o log_cli=true ./AIT-Core/tests/
endif

ifdef DEV
	$(CONDA_ACTIVATE) && cd ./$@ && poetry install > /dev/null && \
	  pre-commit install > /dev/null && pre-commit install -t pre-push > /dev/null
ifdef TOX
	$(CONDA_ACTIVATE) && cd ./$&& tox
endif
endif


AIT-DSN: virtual-env AIT-Core
ifdef AIT_DSN_URL
	test ! -d $@ && git clone -q --branch $(AIT_DSN_BRANCH) $(AIT_DSN_URL) || true

ifeq ($(BRANCH_SWITCH), True)
	 cd $@ && git checkout $(AIT_DSN_BRANCH)
endif 

	$(CONDA_ACTIVATE) && pip install -q -q ./$@
endif 

AIT-GUI: virtual-env AIT-Core
ifdef AIT_GUI_URL
	test ! -d $@ && git clone -q --branch $(AIT_GUI_BRANCH) $(AIT_GUI_URL) || true

ifeq ($(BRANCH_SWITCH), True)
	 cd $@ && git checkout $(AIT_GUI_BRANCH)
endif

	 $(CONDA_ACTIVATE) && pip install -q -q ./$@
endif


conda:
ifeq ($(shell command -v conda 2>&1 /dev/null),)

ifeq ($(wildcard *conda3-*-Linux-x86_64.sh),)
	wget -q $(MINICONDA_URL)
endif
	bash *conda3-*-Linux-x86_64.sh -b > /dev/null || true
endif


virtual-env: conda
	conda create -y -q --name $(project_name) python=$(PYTHON_VERSION) pytest pytest-cov cffi > /dev/null || true
	conda install -y -q -c conda-forge --name $(project_name) traceback-with-variables influxdb > /dev/null
	$(CONDA_ACTIVATE)  && \
	conda env config vars set PYTHONPATH=$(PYTHONPATH) AIT_ROOT=./AIT-Core AIT_CONFIG=$(AIT_CONFIG) LD_PRELOAD=$(LD_PRELOAD)> /dev/null

ifdef DEV
ifeq ($(shell command -v  poetry 2>&1 /dev/null),)
# Cache the install
	conda install -y -q -c conda-forge --name base poetry mypy flake8 > /dev/null
	echo "Installed poetry globally."
endif
	conda install -y -q -c conda-forge --name $(project_name) poetry mypy flake8 > /dev/null
endif



#----------------- Convenience Targets (May be deleted soon)-------------#
touch-paths: AIT-Core AIT-Project
# Run to supress nonexistent path warnings
	$(CONDA_ACTIVATE)  && \
	ait-create-dirs || true

start_sims:
	cd /opt/sunrise/ && ./startupGse.sh
	cd /mnt/fsw/ && ./startup.sh

stop_sims:
	cd /opt/sunrise/ && ./shutdownGse.sh
	cd /mnt/fsw/ && ./shutdown.sh

interactive: server start_sims
	echo "Starting AIT Server and Sims!"
	xdg-open http://localhost:8080

kmc_interactive: kmc_nofork start_sims
	echo "Starting AIT Server and Sims!"
	xdg-open http://localhost:8080

start_sim_tunnel:
	until nc -vzw 2 fss 22; do sleep 2; done
	ssh -v -i /home/ec2-user/.ssh/AIT.pem -g -R fss:42401:localhost:42401 -fN ubuntu@fss

open-port:
ifneq ($(AWS), ec2)
	sudo firewall-cmd --zone=public --permanent --add-port=8080/tcp
	sudo firewall-cmd --reload
endif

close-port:
ifneq ($(AWS), ec2)
	sudo firewall-cmd --zone=public --permanent --remove-port=8080/tcp
	sudo firewall-cmd --reload
endif
