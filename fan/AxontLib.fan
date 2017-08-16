using axon::Axon
using axon::AxonContext
using axon::Fn
using axon::EvalErr
using axon::ThrowErr
using haystack::Etc
using haystack::Dict
using haystack::Grid
using haystack::Number
using skyarcd::Context

** Axon functions for Axont.
const class AxontLib {

	** Verify that cond is true, otherwise throw a test failure exception.
	** 
	** If 'msg' is non-null, include it in a failure exception.
	** Identical to 'verifyTrue()'.
	@Axon
	static Void verify(Bool cond, Str? msg := null) {
		MyTest().verify(cond, msg)
	}
	
	** Verify that 'cond' is 'true', otherwise throw a test failure exception.
	** 
	** If 'msg' is non-null, include it in a failure exception.
	** Identical to 'verify()'.
	@Axon
	static Void verifyTrue(Bool cond, Str? msg := null) {
		MyTest().verifyTrue(cond, msg)
	}
	
	** Verify that 'cond' is 'false', otherwise throw a test failure exception.
	** 
	** If 'msg' is non-null, include it in a failure exception.
	@Axon
	static Void verifyFalse(Bool cond, Str? msg := null) {
		MyTest().verifyFalse(cond, msg)
	}
	
	** Verify that 'a' is 'null', otherwise throw a test failure exception.
	** 
	** If 'msg' is non-null, include it in a failure exception.
	@Axon
	static Void verifyNull(Obj? a, Str? msg := null) {
		MyTest().verifyNull(a, msg)
	}
	
	** Verify that 'a' is not null, otherwise throw a test failure exception.
	** 
	** If 'msg' is non-null, include it in a failure exception.
	@Axon
	static Void verifyNotNull(Obj? a, Str? msg := null) {
		MyTest().verifyNotNull(a, msg)
	}
	
	** Verify that 'a == b', otherwise throw a test failure exception.
	** 
	** If 'msg' is non-null, include it in a failure exception.
	@Axon
	static Void verifyEq(Obj? a, Obj? b, Str? msg := null) {
		MyTest().verifyEq(a, b, msg)
	}
	
	** Verify that 'a != b', otherwise throw a test failure exception.
	** 
	** If 'msg' is non-null, include it in a failure exception.
	@Axon
	static Void verifyNotEq(Obj? a, Obj? b, Str? msg := null) {
		MyTest().verifyNotEq(a, b, msg)
	}

	** Verify that the function throws an Err.
	**
	** Example:
	**   verifyErr =>
	**     parseInt("@#!")
	**
	@Axon
	static Void verifyErr(Fn fn) {
		axonCtx := AxonContext.curAxon(true)
		try {
			fn.call(axonCtx, Obj#.emptyList)
			MyTest().fail("Err not thrown")
		} catch { /* pass */ }
	}
	
	** Verify that the function throws an Err.
	** The contained dis msg must be the same as errMsg.
	**
	** Example:
	**   verifyErrMsg("Invalid Int: '@#!'") () =>
	**     parseInt("@#!")
	** 
	**   verifyErrMsg("poo") () =>
	**     throw { dis: "poo" }
	@Axon
	static Void verifyErrMsg(Str errMsg, Fn fn) {
		axonCtx := AxonContext.curAxon(true)
		try {
			fn.call(axonCtx, Obj#.emptyList)
			MyTest().fail("Err not thrown")
		} catch (Err err) {
			if (err is EvalErr && err.cause != null)
				err = err.cause
			msg := err.msg
			if (err is ThrowErr)
				msg = ((ThrowErr) err).tags.dis ?: "null"
			verifyEq(errMsg, msg)
		}
	}
	
	** Throw a test failure exception.
	** 
	** If 'msg' is non-null, include it in a failure exception.
	@Axon
	static Void fail(Obj? msg := null) {
		MyTest().fail(msg?.toStr)
	}

	** Runs the given list of test functions and returns a Grid of results.
	** 
	** 'tests' may be a name of a top level function, the function itself, or a list of said types.
	@Axon
	static Grid runTests(Obj tests) {
		if (tests isnot Str && tests isnot Fn && tests isnot List)
			throw ArgErr("tests must either be a Str, Fn, or a List of said types - ${tests.typeof}")
		if (tests isnot List)
			tests = [tests]
		
		((Obj?[]) tests).each |test, i| {
			if (test isnot Str && test isnot Fn)
				throw ArgErr("tests[${i}] must either be a Str or Fn")
		}

		axonCtx := AxonContext.curAxon(true)
		results := ((Obj?[]) tests).map |test, i| {
			start  := Duration.now
			fnName := (test as Str) ?: ((Fn) test).name 
			result := Str:Obj?[:] { ordered = true }
				.add("result"	, "")
				.add("name"		, fnName)
				.add("dur"		, null)
				.add("msg"		, "okay")
				.add("trace"	, null)
			
			try {
				testFn	:= (test as Fn) ?: axonCtx.findTop(test, false)
				if (testFn == null)
					throw Err("Unknown func: ${test}")
				msg		:= testFn.call(axonCtx, Obj#.emptyList)
				result["msg"] = msg?.toStr
				
			} catch (Err err) {
				if (err is EvalErr && err.cause != null)
					err = err.cause
				result["result"] = "XXX"
				result["msg"] 	 = err.msg.replace("sys::", "")
				result["trace"]	 = err.traceToStr
			}
			
			result["dur"] = Number(Duration.now - start)
			return Etc.makeDict(result)
		}
		
		return Etc.makeDictsGrid(null, results).reorderCols("result name dur msg trace".split)
	}
	
	** Returns a list of all top level funcs in the project whose name starts with 'test'.
	** Use to quickly run all tests in a project.
	** 
	** Example:
	**   tests().runTests()
	@Axon
	static Fn[] tests() {
		Context.cur(true).funcs { it.name.startsWith("test") && it.name.getSafe(4).isUpper }.map { it.expr }
	}
}

internal class MyTest : Test { }
