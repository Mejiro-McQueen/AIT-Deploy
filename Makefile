miniconda_url:=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
ait_core_url:=https://github.com/NASA-AMMOS/AIT-Core.git
ait_gui_url:=https://github.com/NASA-AMMOS/AIT-GUI.git
project_url:=https://github.jpl.nasa.gov/AIT-Project.git #Your project adaptation
project_name := AIT-Project #The name of the project customization repo and environment in environment.yml

PATH := $(PATH):$(HOME)/miniconda3/bin
SHELL := /bin/bash
#.SHELLFLAGS = -vc

CONDA_ACTIVATE = @source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate

server: AIT-Core AIT-Project conda-config
	$(CONDA_ACTIVATE) $(project_name)&& \
	ait-server&

nofork: AIT-Core AIT-Project conda-config
	$(CONDA_ACTIVATE) $(project_name)&& \
	ait-server

AIT-Core: conda-install
	# This is the AIT_ROOT, so we must clone.
	@ test ! -d $@ && git clone $(ait_core_url) || true

AIT-Project: AIT-GUI AIT-Core conda-install
	# This contains the project customization and configuration files, so we we must clone.
	@ test ! -d $(project_name) && git clone $(project_url) || true

AIT-GUI: AIT-Core
	# We only need to clone this if we're developing for it.
	@ test ! -d $@ && git clone $(ait_gui_url) || true

conda-install:
ifeq ($(shell which conda),)

ifeq ($(wildcard *conda3-*-Linux-x86_64.sh),)
	wget $(miniconda_url)
endif
	bash *conda3-*-Linux-x86_64.sh -b || true
endif

conda-config: AIT-Project conda-install
	conda env create -f environment.yml || true

clean:
	pkill ait-server || true
	conda env remove --name SunRISE-AIT || true
