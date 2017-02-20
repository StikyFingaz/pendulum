# This file is part of orator
# https://github.com/sdispater/orator

# Licensed under the MIT license:
# http://www.opensource.org/licenses/MIT-license
# Copyright (c) 2015 Sébastien Eustace

PENDULUM_RELEASE := $$(sed -n -E "s/VERSION = '(.+)'/\1/p" pendulum/version.py)

# lists all available targets
list:
	@sh -c "$(MAKE) -p no_targets__ | \
		awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {\
			split(\$$1,A,/ /);for(i in A)print A[i]\
		}' | grep -v '__\$$' | grep -v 'make\[1\]' | grep -v 'Makefile' | sort"
# required for list
no_targets__:

# install all dependencies
setup: setup-python

# test your application (tests in the tests/ directory)
test:
	@py.test --cov=pendulum --cov-config .coveragerc tests/ -sq

release: tar wheels_x64 cp_wheels_x64 wheels_i686 cp_wheels_i686 wheel

publish:
	@python -m twine upload dist/pendulum-$(PENDULUM_RELEASE)*

tar:
	python setup.py sdist --formats=gztar

wheel:
	@pip wheel --no-index --no-deps --wheel-dir dist dist/pendulum-$(PENDULUM_RELEASE).tar.gz

wheels_x64: clean_wheels build_wheels_x64

wheels_i686: clean_wheels build_wheels_i686

build_wheels_x64:
	rm -rf wheelhouse/
	docker pull quay.io/pypa/manylinux1_x86_64
	docker run --rm -v `pwd`:/io quay.io/pypa/manylinux1_x86_64 /io/build-wheels.sh

build_wheels_i686:
	rm -rf wheelhouse/
	docker pull quay.io/pypa/manylinux1_i686
	docker run --rm -v `pwd`:/io quay.io/pypa/manylinux1_i686 /io/build-wheels.sh

clean_wheels:
	rm -rf wheelhouse/

cp_wheels_x64:
	cp wheelhouse/*manylinux1_x86_64.whl dist/

cp_wheels_i686:
	cp wheelhouse/*manylinux1_i686.whl dist/

upload_wheels_x64:
	@for f in wheelhouse/*manylinux1_x86_64.whl ; do \
		echo "Upload $$f" ; \
		python -m twine upload $$f ; \
	done

upload_wheels_i686:
	@for f in wheelhouse/*manylinux1_i686.whl ; do \
		echo "Upload $$f" ; \
		python -m twine upload $$f ; \
	done

# run tests against all supported python versions
tox:
	@tox
