#Your project adaptation, otherwise leave blank to work with of AIT defaults (i.e. project_url = )
project_url = https://github.jpl.nasa.gov/SunRISE-Ops/SunRISE-AIT.git
miniconda_url = https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
ait_core_url = https://github.com/NASA-AMMOS/AIT-Core.git
ait_gui_url = https://github.com/NASA-AMMOS/AIT-GUI.git
ait_dsn_url = https://github.com/NASA-AMMOS/AIT-DSN.git

python_version = 3.7

#.SHELLFLAGS = -vc

# End of Configuration
PATH := $(PATH):$(HOME)/miniconda3/bin
SHELL = /bin/bash

CONDA_ACTIVATE = @source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate \
		; conda activate $(project_name)

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
	ait-server&

nofork: virtual-env AIT-Core AIT-Project 
	$(CONDA_ACTIVATE)&& \
	ait-server

AIT-Project: virtual-env AIT-DSN AIT-GUI AIT-Core
ifdef project_url
	@ git clone -q $(project_url) || true
	@ $(CONDA_ACTIVATE) && pip install ./$(project_name)
endif

AIT-Core: virtual-env
	@ test ! -d $@ && git clone -q $(ait_core_url) || true
	@ $(CONDA_ACTIVATE) && pip install ./$@

ifdef TEST
	$(CONDA_ACTIVATE) && \
	pytest --continue-on-collection-errors ./AIT-Core/tests/

	@ echo
	@ echo "!!!!!!!!!!!!! WARNING !!!!!!!!!"
	@ echo "Pytest ran while ignoring continuation errors."
	@ echo "TestFile is not a valid classname. Issue number TBA"
	@ echo "Forcing a fail anyway".
	@ echo
	@ false
endif

AIT-DSN: virtual-env AIT-Core
ifdef ait_dsn_url
	@ git clone -q $(ait_dsn_url) || true
	@ $(CONDA_ACTIVATE) && pip install ./$@
endif 

AIT-GUI: virtual-env AIT-Core
ifdef ait_gui_url
	@ git clone -q $(ait_gui_url) || true
	@ $(CONDA_ACTIVATE) && pip install ./$@
endif

conda:
ifeq ($(shell which conda),)

ifeq ($(wildcard *conda3-*-Linux-x86_64.sh),)
	@ wget $(miniconda_url)
endif
	@ bash *conda3-*-Linux-x86_64.sh -b || true
endif

virtual-env: conda
	@ conda create -y -q --name $(project_name) python=$(python_version) pytest pytest-cov
	@ $(CONDA_ACTIVATE)  && \
	conda env config vars set AIT_ROOT=./AIT-Core AIT_CONFIG=./$(project_name)/config/config.yaml

clean: 
	@ pkill ait-server || true
ifdef $(project_name)
	@ conda env remove --name $(project_name) || true
endif
	@ conda env remove --name AIT-Core || true
