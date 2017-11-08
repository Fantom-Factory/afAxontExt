#Axont v0.0.6
---

LEAD: An extension for SkySpark v3.0.12+ that provides a test runner and assertion functions for testing Axon code.

- [Quick Start](#quickStart)
- [Runner Functions](#runnerFunctions)
- [Assertion Functions](#assertionFunctions)
- [Licensing](#licensing)
- [Release Notes](#releaseNotes)

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

![Axont Result Grid](data:image/png;base64,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)

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

AxonT Ext is free software and an open source project licensed under the permissive [ISC Licence](https://en.wikipedia.org/wiki/ISC_license) by the Internet Systems Consortium - it is similar to the popular MIT licence, only shorter!

