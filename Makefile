change-version:
	echo "Modifying version to: $(version)"
	echo $(version) > VERSION

compile:
	cd scripts && ./build.sh

package:
	bin/packages.sh

deploy:
	bin/deploy.sh
