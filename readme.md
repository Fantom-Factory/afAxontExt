#Axont v0.0.0
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom-lang.org/)
[![pod: v0.0.0](http://img.shields.io/badge/pod-v0.0.0-yellow.svg)](http://www.fantomfactory.org/pods/afAxontExt)
![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)

LEAD: Axont Ext is an extension for **SkySpark v3.0.12+** that provides assertion functions and runners for testing Axon source code.

## Licensing

Axont is an open source project licensed under the [ISC Licence](https://en.wikipedia.org/wiki/ISC_license) - ISC is similar to the MIT licence, only shorter!

## Overview

First create some test functions. Test functions are typically prefixed with `test`, take no arguments, and optionally return `okay` to signify just that.

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

![Axont Results]`data:image/png;base64,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`

## Install

Install `Axont` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afAxontExt

Or install `Axont` with [fanr](http://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afAxontExt

To use in a [Fantom](http://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afAxontExt 0.0"]

## Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afAxontExt/) - the Fantom Pod Repository.

## Runner Functions

### runTests(tests)

Runs the given list of test functions and returns a Grid of results.

`tests` may be a name of a top level function, the function itself, or a list of said types.

### tests()

Returns a list of all top level funcs in the project whose name starts with `test`. Use to quickly run all tests in a project.

Example:

    tests().runTests()

## Assert Functions

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

Verify that the function throws an Err.

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

