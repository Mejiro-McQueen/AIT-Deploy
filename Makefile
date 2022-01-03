project_url = https://github.jpl.nasa.gov/SunRISE-Ops/SunRISE-AIT.git #Your project adaptation
miniconda_url = https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
ait_core_url = https://github.com/NASA-AMMOS/AIT-Core.git
ait_gui_url = https://github.com/NASA-AMMOS/AIT-GUI.git

#.SHELLFLAGS = -vc

# End of Configuration
project_name := $(shell basename $(project_url) .git)
PATH := $(PATH):$(HOME)/miniconda3/bin
SHELL = /bin/bash

CONDA_ACTIVATE = @source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate

server: AIT-Core AIT-Project conda-config
	$(CONDA_ACTIVATE) $(project_name)&& \
	ait-server&

nofork: AIT-Core AIT-Project conda-config
	$(CONDA_ACTIVATE) $(project_name)&& \
	ait-server

AIT-Core: conda-install
	@ test ! -d $@ && git clone $(ait_core_url) || true

core-test: AIT-Core conda-config
	$(CONDA_ACTIVATE) $(project_name)&& \
	pytest --continue-on-collection-errors ./AIT-Core/tests/

	@ echo
	@ echo "!!!!!!!!!!!!! WARNING !!!!!!!!!"
	@ echo "Pytest ran while ignoring continuation errors."
	@ echo "TestFile is not a valid classname. Issue number TBA"
	@ echo "Forcing a fail anyway".
	@ echo
	@ false

AIT-Project: AIT-GUI AIT-Core conda-install
	@ test ! -d $(project_name) && git clone $(project_url) || true

AIT-GUI: AIT-Core
	@ test ! -d $@ && git clone $(ait_gui_url) || true

conda-install:
ifeq ($(shell which conda),)

ifeq ($(wildcard *conda3-*-Linux-x86_64.sh),)
	wget $(miniconda_url)
endif
	bash *conda3-*-Linux-x86_64.sh -b || true
endif


define exp
	-e "s/AIT_PROJECT/$(project_name)/"\
	-e "s#AIT_CORE_URL#$(ait_core_url)#"\
	-e "s#AIT_GUI_URL#$(ait_gui_url)#"\
	-e "s#PROJECT_URL#$(project_url)#"\

endef
conda-config: AIT-Project conda-install
	@sed $(exp)environment_template.yml > environment.yml

	@ conda env create -f environment.yml || true

clean:
	@ pkill ait-server || true 
	@ conda env remove --name $(project_name) || true
