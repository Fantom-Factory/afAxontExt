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

using skyarc::User
using skyarcd::Proj
using haystack::Ref
using axon::FantomFn
using haystack::Marker
using axon::Loc

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
		if (a is Dict && b is Dict) {
			// Dicts with nulls are NOT the same!?
			// https://skyfoundry.com/forum/topic/5082
			o1 := Etc.makeDict(Etc.dictToMap(a).exclude { it == null })
			o2 := Etc.makeDict(Etc.dictToMap(b).exclude { it == null })
			if (Etc.dictEq(o1, o2) == false)
				MyTest().verifyEq(o1, o2, msg)
			return
		}

		if (!areEq(a, b))
			MyTest().verifyEq(a, b, msg)
	}
	
	** Verify that 'a != b', otherwise throw a test failure exception.
	** 
	** If 'msg' is non-null, include it in a failure exception.
	@Axon
	static Void verifyNotEq(Obj? a, Obj? b, Str? msg := null) {
		if (areEq(a, b))
			MyTest().verifyNotEq(a, b, msg)
	}

	** Verify that the function throws an Err.
	** The err msg is returned so you may do further (regex) tests on it.
	**
	** Example:
	**   syntax: axon
	**   verifyErr =>
	**     parseInt("@#!")
	**
	@Axon
	static Str verifyErr(Fn fn) {
		axonCtx := AxonContext.curAxon(true)
		try {
			fn.call(axonCtx, Obj#.emptyList)
			MyTest().fail("Err not thrown")
		} catch (Err err) {
			/* pass */
			return getErrMsg(err)
		}
		throw Err("WTF?")
	}
	
	** Verify that the function throws an Err.
	** The contained dis msg must be the same as errMsg.
	**
	** Example:
	**   syntax: axon
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
			verifyEq(errMsg, getErrMsg(err))
		}
	}
	
	** Throw a test failure exception.
	** 
	** If 'msg' is non-null, include it in a failure exception.
	@Axon
	static Void fail(Obj? msg := null) {
		MyTest().fail(msg?.toStr)
	}
	
	** Returns a list of all top level funcs in the project whose name starts with 'test'.
	** Use to quickly run all tests in a project.
	** 
	** Example:
	**   syntax: axon
	**   tests().runTests()
	@Axon
	static Fn[] tests() {
		Context.cur(true).funcs { it.name.startsWith("test") && it.name.getSafe(4).isUpper }.map { it.expr }
	}
	
	** Runs the given list of test functions and returns a Grid of results.
	** 
	** 'tests' may be a name of a top level function, the function itself, or a list of said types.
	** 
	** 'options' is a 'Dict' which may contains the following:
	**  - 'setup'         - a func that is run *before* every test function
	**  - 'teardown'      - a func that is run *after* every test function
	**  - 'runInNewProj'  - a marker to denote that each test should be run in its own test project. The 'setup()' and 'teardown()' fns are run in the same proj as the test.
	**  - 'exts'          - a list of string ext names that should be enabled in the new proj.
	**  - 'recs'          - a string filter expr of all records to be copied over to the new proj.
	** 
	** When running tests in a new project, unless 'exts' or 'recs' are defined, then all enabled 
	** exts in current project are also enabled in the new project. And all 'func or def' records
	** are copied over also.  
	@Axon
	static Grid runTests(Obj tests, Dict? opts := null) {
		
		// TODO log test start and end - have listener funcs
		
		if (tests isnot Str && tests isnot Fn && tests isnot List)
			throw ArgErr("tests must either be a Str, Fn, or a List of said types - ${tests.typeof}")
		if (tests isnot List)
			tests = [tests]
	
		((Obj?[]) tests).each |test, i| {
			if (test isnot Str && test isnot Fn)
				throw ArgErr("tests[${i}] must either be a Str or Fn")
		}

		opts		 = opts ?: Etc.emptyDict
		setupFn		:= (Fn?) opts["setup"]
		teardownFn	:= (Fn?) opts["teardown"]
		
		results := ((Obj?[]) tests).map |test, i| {
			start  := Duration.now
			fnName := (test as Str) ?: ((Fn) test).name 
			result := Str:Obj?[:] { ordered = true }
				.add("result"	, "okay")
				.add("name"		, fnName)
				.add("dur"		, null)
				.add("msg"		, null)
				.add("trace"	, null)
			
			callAxonFn := null as |Obj? axonFn -> Obj?|
			runTestFn  := |->| {
				try {
					callAxonFn(setupFn)

					result["msg"] = callAxonFn(test)?.toStr
	
				} catch (Err err) {
					result["result"] = "XXX"
					result["msg"]    = err.msg.replace("sys::", "")
					result["trace"]	 = traceErr(err)
				}

				try	callAxonFn(teardownFn)
				catch (Err err) {
					// don't overwrite existing err msgs - 'cos what came first is likely to be more important
					if (result["result"].toStr == "okay") {
						result["result"] = "XXX"
						result["msg"]    = err.msg.replace("sys::", "")
						result["trace"]	 = traceErr(err)
					}
				}
			}
			
			runInNewProj := opts.get("runInNewProj")
			if (runInNewProj == null || runInNewProj == false) {
				callAxonFn = |Obj? axonFn -> Obj?| { AxontLib.callAxonFn(axonFn) }
				runTestFn()
			}
			else
				AxontRunner(opts).runInNewProj |runner| {
					callAxonFn = |Obj? axonFn -> Obj?| { runner.callAxonFn(axonFn) }
					runTestFn()
					return null
				}
	
			result["dur"] = Number((Duration.now - start).floor(1ms), Unit("ms"))
			return Etc.makeDict(result)
		}
		
		return Etc.makeDictsGrid(null, results).reorderCols("result name dur msg trace".split)
	}

	** Convenience for '[...].runTests({runInNewProj})'.
	@Axon
	static Grid runTestsInNewProj(Obj tests, Dict? opts := null) {
		runTests(tests, 
			opts == null
				? Etc.makeDict1("runInNewProj", Marker.val)
				: Etc.dictSet(opts, "runInNewProj", Marker.val)
		)
	}
	
	** Calls the given Axon Fn (or fn name) in the context of the new project.
	static private Obj? callAxonFn(Obj? axonObj, Obj?[]? args := null) {
		if (axonObj == null)
			return null

		axonCtx := Context.cur(true)
		loc		:= Loc("afAxontExt.runTests")
		axonFn  := (axonObj as Fn) ?: axonCtx.findTop(axonObj.toStr, false)
		if (axonFn == null)
			throw Err("Unknown func: ${axonObj}")

		return axonCtx.callInNewFrame(axonFn, args ?: Obj#.emptyList, loc)
	}

	private static Str getErrMsg(Err err) {
		if (err is EvalErr && err.cause != null)
			err = err.cause
		msg := err.msg
		if (err is ThrowErr)
			msg = ((ThrowErr) err).tags.dis ?: "null"
		return msg
	}
	
	private static Str traceErr(Err err) {
		traceStr := StrBuf()
		if (err is EvalErr) {
			traceStr.add(err.toStr).addChar('\n')
			traceStr.addChar('\n')
			traceStr.add("-- Axon trace: --\n")
			traceStr.add((err as EvalErr).axonTrace).addChar('\n')
			traceStr.add("-- Fantom trace: --\n")
			if (err.cause != null) err = err.cause
		}
		traceStr.add(err.trace(traceStr.out))
		return traceStr.toStr
	}
	
	** Lists and Dicts have their eq problems - so let's 
	private static Bool areEq(Obj? o1, Obj? o2) {
		if (o1 is List && o2 is List) {
			// List.equals() also compares the list type - which we don't want
			l1 := (List) o1
			l2 := (List) o2
			if (l1.size != l2.size) return false
			return l1.all |meh, i| { areEq(l1[i], l2[i]) }
		}

		if (o1 is Dict && o2 is Dict) {
			// Dicts with nulls are NOT the same!?
			// https://skyfoundry.com/forum/topic/5082
			o1 = Etc.makeDict(Etc.dictToMap(o1).exclude { it == null })
			o2 = Etc.makeDict(Etc.dictToMap(o2).exclude { it == null })
			return Etc.dictEq(o1, o2)
		}

		return o1 == o2
	}
}

internal class MyTest : Test { }
