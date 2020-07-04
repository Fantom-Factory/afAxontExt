# Axont v0.0.10
---

An extension for SkySpark v3.0.12+ that provides a unit test runner and assertion functions for testing Axon code.

* [Quick Start](#quickStart)
* [Licensing](#licensing)
* [Version Notes](#releaseNotes)


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

## <a name="releaseNotes"></a>Version Notes

**v0.0.10**

* Chg: `verifyEq()` and `verifyNotEq()` are more lenient when testing Lists and Dicts. (e.g. the backing Fantom List type is ignored, `Etc.dictEq()` is now used but also patched for [this bug](https://skyfoundry.com/forum/topic/5082).)


**v0.0.8**

* Chg: Ensure the Axon trace is captured by `runTests()` results. (Thanks go to John MacEnri / Crawley Carbon for the pull requst.)


**v0.0.6**

* Chg: Renamed extension from `axont` to `afAxont` for consistency with other Alien-Factory products.


**v0.0.4**

* New: Added `setup` and `teadown` to `runTests()` options.
* New: Created alien icon for ext.
* Chg: `verifyErr` returns the err msg should you wish to perform further (regex) tests on it.


**v0.0.2**

* New: Preview release, created to test [Axonator](https://stackhub.org/package/afAxonatorExt) - *the Axon source code encryptor and obfuscator*.


