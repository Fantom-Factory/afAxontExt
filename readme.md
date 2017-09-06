#Axont v0.0.4
---

LEAD: An extension for SkySpark v3.0.12+ that provides a test runner and assertion functions for testing Axon code.

## Quick Start

First create some test functions in Axon. Test functions are typically prefixed with `test`, take no arguments, and optionally return `okay` to signify just that.

```
testPassExample : () => do
  expected : "foo bar"
  actual   : "foo bar" // this bit should do some work!

  // assert the result
  verifyEq(expected, actual)

  "okay"
end

testFailExample : () => do
  expected : "foo bar"
  actual   : "poo"

  // assert the result
  verifyEq(expected, actual)

  "okay"
end
```

Then pass them to the test runner to have them executed.

```
// run tests
[
  testPassExample,
  testFailExample
].runTests()
```

Results are returned in a handy grid:

![Axont Result Grid](http://eggbox.fantomfactory.org/pods/afAxontExt/doc/testResults.png)

## Runner Functions

### runTests(tests)

Runs the given list of test functions and returns a Grid of results.

`tests` may be a name of a top level function, the function itself, or a list of said types.

`options` is a `Dict` which may contains the following:

- `setup` - a func that is run *before* every test function
- `teardown` - a func that is run *after* every test function

### tests()

Returns a list of all top level funcs in the project whose name starts with `test`. Use to quickly run all tests in a project.

Example:

    tests().runTests()

## Assertion Functions

### verify(cond, msg: null)

Verify that cond is true, otherwise throw a test failure exception.

If `msg` is non-null, include it in a failure exception. Identical to `verifyTrue()`.

### verifyTrue(cond, msg: null)

Verify that `cond` is `true`, otherwise throw a test failure exception.

If `msg` is non-null, include it in a failure exception. Identical to `verify()`.

### verifyFalse(cond, msg: null)

Verify that `cond` is `false`, otherwise throw a test failure exception.

If `msg` is non-null, include it in a failure exception.

### verifyNull(a, msg: null)

Verify that `a` is `null`, otherwise throw a test failure exception.

If `msg` is non-null, include it in a failure exception.

### verifyNotNull(a, msg: null)

Verify that `a` is not null, otherwise throw a test failure exception.

If `msg` is non-null, include it in a failure exception.

### verifyEq(a, b, msg: null)

Verify that `a == b`, otherwise throw a test failure exception.

If `msg` is non-null, include it in a failure exception.

### verifyNotEq(a, b, msg: null)

Verify that `a != b`, otherwise throw a test failure exception.

If `msg` is non-null, include it in a failure exception.

### verifyErr(fn)

Verify that the function throws an Err. The err msg is returned so you may do further (regex) tests on it.

Example:

    verifyErr =>
      parseInt("@#!")

### verifyErrMsg(msg, fn)

Verify that the function throws an Err. The contained dis msg must be the same as errMsg.

Example:

    verifyErrMsg("Invalid Int: '@#!'") () =>
      parseInt("@#!")
    
    verifyErrMsg("poo") () =>
      throw { dis: "poo" }

## Licensing

Escape the Mainframe is free software an open source project licensed under the permissive [ISC Licence](https://en.wikipedia.org/wiki/ISC_license) by the Internet Systems Consortium - it is similar to the popular MIT licence, only shorter!

