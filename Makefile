#Your project adaptation, otherwise comment the line
project_url = https://github.jpl.nasa.gov/SunRISE-Ops/SunRISE-AIT.git
miniconda_url = https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
ait_core_url = git@github.com:Mejiro-McQueen/AIT-Core.git 
ait_gui_url = git@github.com:Mejiro-McQueen/AIT-GUI.git 
ait_dsn_url = git@github.com:Mejiro-McQueen/AIT-DSN.git 

python_version = 3.8

# DEV=true
# TOX=true

#.SHELLFLAGS = -vc

# End of Configuration
PATH := $(HOME)/miniconda3/bin:$(PATH)
SHELL := env PATH=$(PATH) /usr/bin/env bash

KMC_CLIENT := /ammos/kmc-crypto-client/lib/python3.8/site-packages


PYTHONPATH = $(KMC_CLIENT)

CONDA_ACTIVATE = source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate \
		; conda activate $(project_name) &> /dev/null


ifdef project_url
	project_name := $(shell basename $(project_url) .git)
else
	project_name = "AIT-Core"
endif

ifdef TEST
	project_name = "AIT-Core"
endif


server: virtual-env AIT-Core AIT-Project
	$(CONDA_ACTIVATE)&& \
	LD_PRELOAD=/usr/lib64/libcrypto.so.1.1 ait-server&


nofork: virtual-env AIT-Core AIT-Project 
	$(CONDA_ACTIVATE)&& \
	LD_PRELOAD=/usr/lib64/libcrypto.so.1.1 traceback-with-variables ait-server


kmc_shell: virtual-env AIT-Core
	$(CONDA_ACTIVATE)&& \
	LD_PRELOAD=/usr/lib64/libcrypto.so.1.1 bash -c python \


kmc_nofork: create_db nofork


kmc_server: create_db server 


AIT-Project: virtual-env AIT-DSN AIT-GUI AIT-Core
ifdef project_url
	 test ! -d $(project_name) && git clone -q $(project_url) || true
	 $(CONDA_ACTIVATE) && pip install -q -q ./$(project_name)
endif


AIT-Core: virtual-env
	 test ! -d $&& git clone -q $(ait_core_url) || true
ifndef DEV
	 $(CONDA_ACTIVATE) && pip install -q -q ./$@
endif

ifdef TEST
	$(CONDA_ACTIVATE) && \
	pytest -v -s -o log_cli=true ./AIT-Core/tests/
endif

ifdef DEV
	$(CONDA_ACTIVATE) && cd ./$&& poetry install > /dev/null && \
	  pre-commit install > /dev/null && pre-commit install -t pre-push > /dev/null
ifdef TOX
	$(CONDA_ACTIVATE) && cd ./$&& tox
endif
endif


AIT-DSN: virtual-env AIT-Core
ifdef ait_dsn_url
	test ! -d $&& git clone -q $(ait_dsn_url) || true
	$(CONDA_ACTIVATE) && pip install -q -q ./$@
endif 

AIT-GUI: virtual-env AIT-Core
ifdef ait_gui_url
	test ! -d $&& git clone -q $(ait_gui_url) || true
	$(CONDA_ACTIVATE) && pip install -q -q ./$@
endif


conda:
ifeq ($(shell command -v conda 2>&1 /dev/null),)

ifeq ($(wildcard *conda3-*-Linux-x86_64.sh),)
	wget -q $(miniconda_url)
endif
	bash *conda3-*-Linux-x86_64.sh -b > /dev/null || true
endif


virtual-env: conda
	conda create -y -q --name $(project_name) python=$(python_version) pytest pytest-cov cffi > /dev/null || true
	conda install -y -q -c conda-forge --name $(project_name) traceback-with-variables > /dev/null	
	$(CONDA_ACTIVATE)  && \
	conda env config vars set PYTHONPATH=$(PYTHONPATH) AIT_ROOT=./AIT-Core AIT_CONFIG=./$(project_name)/config/config.yaml > /dev/null

ifdef DEV
ifeq ($(shell command -v  poetry 2>&1 /dev/null),)
# Cache the install
	conda install -y -q -c conda-forge --name base poetry mypy flake8 > /dev/null
	echo "Installed poetry globally."
endif
	conda install -y -q -c conda-forge --name $(project_name) poetry mypy flake8 > /dev/null
endif


create_db:
	mysql -u root < ./sql_scripts/create_sadb.sql | true
	mysql -u root < ./sql_scripts/create_sadb_ait_test_security_associations.sql | true


clean: stop_sims clean_db
	pkill ait-server || true
	conda env remove --name $(project_name) &> /dev/null || true 
	conda env remove --name AIT-Core &> /dev/null || true


touch-paths: AIT-Core AIT-Project
# Run to supress nonexistent path warnings
	$(CONDA_ACTIVATE)  && \
	ait-create-dirs || true


start_sims:
	/opt/sunrise/startupGse.sh
	/mnt/fsw/./startup.sh


stop_sims:
	/opt/sunrise/shutdownGse.sh | true
	/mnt/fsw/./shutdown.sh | true


clean_db:
	mysql -u root < ./sql_scripts/delete_sadb.sql | true


interactive: server start_sims
	echo "Starting AIT Server and Sims!"
	xdg-open http://localhost:8080


kmc_interactive: create_db interactive
