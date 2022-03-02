JPLNET := https://tester:g3tpackag3s@asis-repo1.jpl.nasa.gov/testing/asis/rhel8/x86_64/RPMS/MGSS-asis-repo-testing-jplnet-latest.el8.noarch.rpm

MISSION_NET:= https://tester:g3tpackag3s@sajs-repo1.fltops.jpl.nasa.gov/testing/asis/rhel8/x86_64/RPMS/MGSS-asis-repo-testing-fltops-latest.el8.noarch.rpm

MGSS_REPO := $(JPLNET)

MANIFEST := MGSS-ammos-system-current-A31.0.sunrisekmcdev.3.noarch

.PHONY : all
all : install-manifest open-port

config-mgss-repo: 
	sudo dnf install -y $(MGSS_REPO) 

install-manifest: install-jdk config-mgss-repo
	sudo dnf -y install $(MANIFEST)

uninstall-manifest:
	sudo dnf -y remove $(MANIFEST)

uninstall-mgss-repo:
	sudo dnf remove -y MGSS-asis-repo-testing-jplnet.noarch

install-jdk:
	sudo dnf install -y java-11-openjdk-headless.x86_64

uninstall-jdk:
	sudo dnf remove -y java-11-openjdk-headless.x86_64

open-port:
	sudo firewall-cmd --zone=public --permanent --add-port=8443/tcp
	sudo firewall-cmd --reload

close-port:
	sudo firewall-cmd --zone=public --permanent --remove-port=8443/tcp
	sudo firewall-cmd --reload

clean: close-port uninstall-manifest uninstall-mgss-repo
	@echo
	@echo "Manually remove /opt/ammos"
	@echo "Manually delete user: MGSS CM User"
	@echo "Manually delete user: Tomcat Admin User"
