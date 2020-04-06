TMP := $(shell mktemp -d -u)
UPDATE_BRANCH ?= "maistra-1.2"

update-common:
	@mkdir -p $(TMP)
	@git clone -q --depth 1 --single-branch --branch $(UPDATE_BRANCH) https://github.com/jwendell/rpm-common $(TMP)/rpm-common
	@cd $(TMP)/rpm-common ; git rev-parse HEAD >files/common/.rpm-common.sha
	@rm -fr common
	@cp -a $(TMP)/rpm-common/files/* $(shell pwd)
	@rm -fr $(TMP)/rpm-common
