#!/bin/bash

BASEDIR=`dirname $0`/..

if [ ! -d "$BASEDIR/env-ut" ]; then
    virtualenv -p python3.4 -q $BASEDIR/env-ut --prompt="($COMMAND_NAME) " > /dev/null 2>&1
    echo "New virtualenv for UT created."

    source $BASEDIR/env-ut/bin/activate
    echo "New virtualenv for UT activated."

    pip install -r requirements.txt > /dev/null 2>&1
    pip install -e $BASEDIR | grep ^Successfully
    echo "Requirements for UT installed (new venv)."

    mkdir -p target/surefire-reports
    python bin/mustachecker.py
elif [ -f "$BASEDIR/env-ut/bin/activate" -o "$BASEDIR/setup.py" -nt "$BASEDIR/env-ut/bin/activate" ]; then
    source $BASEDIR/env-ut/bin/activate
    echo "Existing virtualenv for UT activated."

    pip install -r requirements.txt > /dev/null 2>&1
    pip install -e $BASEDIR | grep ^Successfully
    echo "Requirements for UT installed (existing venv)."

    mkdir -p target/surefire-reports
    python bin/mustachecker.py
fi
