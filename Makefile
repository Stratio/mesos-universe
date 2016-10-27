all: compile package

change-version:
	echo "Modifying version to: $(version)"
	echo $(version) > VERSION

clean:
	rm -Rf target

compile:
	cd scripts && ./build.sh

package:
	bin/packages.sh

deploy:
	bin/deploy.sh

code-quality:
	echo "Nothing to do here"
