from __future__ import absolute_import
import pydash
import pystache
import re
import os
import sys
import glob
import json
import jsonpath_rw_ext
import unittest
from functools import reduce
from junit_xml import TestSuite, TestCase
import progressbar

## Lazy Method Chaining
class Validate(object):
    """Enables chaining of pydash functions."""

    def __init__(self, value):
        self._value = value

    def value(self):
        """Return current value of the chain operations."""
        self._value = validate_mustache(self._value[0], self._value[1])
        return self._value

    @staticmethod
    def get_method(name):
        """Return valid pydash method."""
        method = getattr(pydash, name, None)

        if not callable(method):
            raise pydash.InvalidMethod('Invalid pydash method: {0}'.format(name))

        return method

    def __getattr__(self, attr):
        """Proxy attribute access to pydash."""
        return ValidateWrapper(self._value, self.get_method(attr))

class ValidateWrapper(object):
    """Wrap pydash method call within a ValidateWrapper context."""
    def __init__(self, value, method):
        self._value = value
        self.method = method
        self.args = ()
        self.kargs = {}

    def unwrap(self):
        """Execute method with _value, args, and kargs. If _value is an
        instance of ValidateWrapper, then unwrap it before calling method.
        """
        if isinstance(self._value, ValidateWrapper):
            self._value = self._value.unwrap()
        return self.method(self._value, *self.args, **self.kargs)

    def __call__(self, *args, **kargs):
        """Invoke the method with value as the first argument and return a new
        Validate object with the return value.
        """
        self.args = args
        self.kargs = kargs
        return Validate(self)


def validate(value):
    """Creates a 'Validate' object which wraps the given value to enable
    intuitive method chaining. Chaining is lazy and won't compute a final value
    until 'Validate.value' is called.
    """
    return Validate(value)
## End Lazy Method Chaining


## Validation
# Transform dot notation to yml
# INPUT: {'security.kerberos.krb5conf': 'value', 'security.stratio.ssl': True, 'hdfs.config-url': 'value'}
# OUTPUT: { 'security': { 'kerberos': { 'krb5conf': 'value' }, 'stratio': { 'ssl': True } }, 'hdfs': { 'config-url': 'value'} }
# a: list of variables
# return:
# output: dictionary with variables in json format, without dot notation
def dot_to_json(a):
    output = {}
    for key, value in a.items():
        path = key.split('.')
        if path[0] == 'json':
            path = path[1:]
        target = reduce(lambda d, k: d.setdefault(k, {}), path[:-1], output)
        target[path[-1]] = value
    return output

# Obtain all conditional variables from config files and replace variables with 123456789
# config_file: application config.json file
# mustache_file: application marathon.json.mustache file
# return:
# condvars: dictionary with all conditional variables
# content: mustache file with variable modified
def obtain_cond_vars(config_file, mustache_file):
    condvars = {}

    # Read json in config file
    with open(config_file) as json_data:
        fdc = json.load(json_data)

    # Open mustache file to read
    fdm = open(mustache_file, "r")

    # Read mustache file to obtain conditional variables and replace other ones
    content = ""
    for line in fdm:
        if re.search("{{#", line) or re.search("{{^", line):
            # Obtain condition in mustache
            cond = line.strip()[3:][:-2]

            if not condvars.__contains__(cond):
                # Find type of condition in config file
                found = jsonpath_rw_ext.parse('$.properties.' + cond.replace('.', '.properties.' ) + '.type').find(fdc)

                if not found:
                    print("ERROR: Condition '" + cond + "' is NOT defined in config file!!")
                    content = content + line
                    continue

                type = found[0].value

                # Based on type add different values to condvars
                if str(type) == "string":
                    condvars.setdefault(cond, "testvalue")
                elif str(type) == "number" or str(type) == "integer":
                    condvars.setdefault(cond, 3)
                elif str(type) == "boolean":
                    condvars.setdefault(cond, True)
        else:
            if re.search("{{[a-zA-Z][a-zA-Z_0-9_.-]*}}", line):
                line = re.sub(r'{{[a-zA-Z_.-][a-zA-Z_0-9_.-]*}}', '123456789', line)
        content = content + line

    return condvars, content


# Validate a mustache using a set of variables
# combination: list of variables
# mustache: mustache to validate
# return:
# valid json if ok
# exception if failure
def validate_mustache(combination, mustache):
    # Transform dot combinations to expected one
    combinationmod = dot_to_json(combination)

    # Generate and validate json from mustache based on vars defined
    res = pystache.render(mustache, combinationmod)

    try:
        return json.loads(res)
    except:
        sys.stderr.write(res)
        raise

# Obtain a specific combination
# condvars: all conditional variables { 'a': 1, 'b': 2}
# array: representing variables to return [ True, False ]
# return:
# comb: desired combination {'a': '1'}
def obtain_combination(condvars, array):
    comb = {}
    for i in range(0, condvars.__len__()):
        if array[i]:
            key = list(condvars)[i]
            comb.setdefault(key, condvars.get(key))

    return comb

## End Validation


## Automatic tests generation
class TestsContainer(unittest.TestCase):
    longMessage = True

# Assert
# description: test description
# a: result from validation
# b: expected result
# return:
# test: test function
def make_test_function(description, a, b):
    def test(self):
        self.assertIsInstance(a.value(), b, description)
    return test
## End Automatic tests generation


## Main. Test all possible scenarios
if __name__ == '__main__':
    mustache_files = glob.glob('paas-universe/repo/packages/*/*/*/marathon.json.mustache')

    test_suites = []
    for mustache_file in mustache_files:
        print("\n\nChecking file: ", mustache_file)

        test_cases = []

        config_file = os.path.dirname(mustache_file) + '/config.json'

        condvars, mustache = obtain_cond_vars(config_file, mustache_file)

        len = condvars.__len__()
        limit = 2 ** len

        bar = progressbar.ProgressBar(max_value=limit).start()
        for x in range(0, limit):
            array = [ bool(int(x)) for x in bin(x)[2:].zfill(len) ]
            comb = obtain_combination(condvars, array)

            test_func = make_test_function('validate_{0}_{1}'.format(os.path.dirname(mustache_file).strip()[3:], comb), Validate([comb, mustache]), dict)
            setattr(TestsContainer, 'test_{0}_{1}'.format(os.path.dirname(mustache_file).strip()[3:], comb), test_func)

            test_case = TestCase("vars: " + format(comb), 'MustacheValidator')

            bar.update(x)

            try:
                isinstance(Validate([comb, mustache]).value(), dict)
            except ValueError:
                test_case.add_failure_info("Test Case Failed!")
                test_cases.append(test_case)

        bar.finish()
        test_suites.append(TestSuite("validate: " + mustache_file, test_cases))

    with open('target/surefire-reports/mustache_validator.xml', 'w+') as f:
        TestSuite.to_file(f, test_suites, prettyprint=True)

    unittest.main()
