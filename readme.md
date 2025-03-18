# Axont v0.1.2
---

An extension for SkySpark v3.1.1+ that provides a unit test runner and assertion functions for testing Axon code.

* [Quick Start](#quickStart)
* [Licensing](#licensing)


AxonT source code is available on [Fantom Factory's GitHub - AxonT](https://github.com/Fantom-Factory/afAxontExt).

## <a name="quickStart"></a>Quick Start

First create some test functions in Axon. Test functions are typically prefixed with `test`, take no arguments, and optionally return `okay` to signify just that.

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
    

Then pass them to the test runner to have them executed.

    // run tests
    [
      testPassExample,
      testFailExample
    ].runTests()
    

Results are returned in a handy grid:

![Axont Result Grid](http://eggbox.fantomfactory.org/pods/afAxontExt/doc/testResults.png)

## <a name="licensing"></a>Licensing

AxonT Ext is free software and an open source project licensed under the permissive [ISC Licence](https://en.wikipedia.org/wiki/ISC_license) by the Internet Systems Consortium - it is similar to the popular MIT licence, only shorter!

