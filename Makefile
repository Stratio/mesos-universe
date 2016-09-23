compile:
	cd scripts && ./build.sh

package:
	bin/packages.sh

deploy:
	bin/deploy.sh
