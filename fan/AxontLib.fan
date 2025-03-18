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
using haystack::Ref
using axon::FantomFn
using haystack::Marker
using axon::Loc

using projMod::StdProjLib

** Axon functions for Axont.
const class AxontLib {

	
	** Runs the given Fn in a new virgin SkySpark project.
	@Axon
	static Obj? runInTestProj(Fn fn) {
		curCtx		:= ctx
		loc			:= Loc("afAxontExt.runInTestProj")
		projNewFn	:= curCtx.findTop("projNew")		// projMod::StdProjLib.projNew()
		projDelFn	:= curCtx.findTop("projDelete")		// projMod::StdProjLib.projDelete()
		
		// projName MUST 
		//  - be at least 4 chars
		//  - not contain the reserved strings "axon", "proj"
		// add some random chars to avoid clashes with any existing projs 
		projName	:= "test_" + Int.random(0..9999).toStr.padl(4, '0')
		projDict	:= projNewFn.callx(curCtx, [Etc.makeDict([
			"name"		: projName,
			"dis"		: "AxonT Test Proj",
			"projMeta"	: Marker.val,
		])], loc)
		
		// the curFrame is runInTestProj(), so parent vars in in stack[-2]
		// not sure why the vars aren't returned through ctx.varsInScope() ???
		proj		:= curCtx.sys.proj.local(projName)
		vars		:= curCtx->stack->get(-2)->vars

		try {
			suUser	:= makeSyntheticUser("axontTestUser", "su")
			axonCtx := Context.make(ctx.sys, suUser, proj)
			result	:= axonCtx.callInNewFrame(fn, Obj#.emptyList, loc, vars)
			return result
		}
		finally projDelFn.callx(curCtx, [Ref("p:${projName}"), Date.today.toIso], loc)
	}

	private static Context ctx(Bool checked := true) {
		Context.cur(checked)
	}
	private static User makeSyntheticUser(Str username, Str role, [Str:Obj]? extraTags := null) {
		tags := Str:Obj[
			"id"		: Ref("u:$username"), 
			"username"	: username, 
			"userRole"	: role, 
			"mod"		: DateTime.now
		]
		if (extraTags != null) tags.setAll(extraTags)
		return User(Etc.makeDict(tags))
	}	
	
	
	
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

	** Runs the given list of test functions and returns a Grid of results.
	** 
	** 'tests' may be a name of a top level function, the function itself, or a list of said types.
	** 
	** 'options' is a 'Dict' which may contains the following:
	**  - 'setup' - a func that is run *before* every test function
	**  - 'teardown' - a func that is run *after* every test function
	@Axon
	static Grid runTests(Obj tests, Dict? options := null) {
		
		// TODO log test start and end - have listener funcs
		
		if (tests isnot Str && tests isnot Fn && tests isnot List)
			throw ArgErr("tests must either be a Str, Fn, or a List of said types - ${tests.typeof}")
		if (tests isnot List)
			tests = [tests]
	
		((Obj?[]) tests).each |test, i| {
			if (test isnot Str && test isnot Fn)
				throw ArgErr("tests[${i}] must either be a Str or Fn")
		}

		opts		:= Etc.dictToMap(options)
		setupFn		:= (Fn?) opts["setup"]
		teardownFn	:= (Fn?) opts["teardown"]
		
		axonCtx := AxonContext.curAxon(true)
		results := ((Obj?[]) tests).map |test, i| {
			start  := Duration.now
			fnName := (test as Str) ?: ((Fn) test).name 
			result := Str:Obj?[:] { ordered = true }
				.add("result"	, "okay")
				.add("name"		, fnName)
				.add("dur"		, null)
				.add("msg"		, null)
				.add("trace"	, null)
			
			try {
				setupFn?.call(axonCtx, Obj#.emptyList)

				testFn	:= (test as Fn) ?: axonCtx.findTop(test, false)
				if (testFn == null)
					throw Err("Unknown func: ${test}")
				msg		:= testFn.call(axonCtx, Obj#.emptyList)
				result["msg"] = msg?.toStr
				
				
			} catch (Err err) {
				result["result"] = "XXX"
				result["msg"]    = err.msg.replace("sys::", "")
				result["trace"]	 = traceErr(err)
			}

			try	teardownFn?.call(axonCtx, Obj#.emptyList)
			catch (Err err) {
				// don't overwrite existing err msgs - 'cos what came first is likely to be more important
				if (result["result"].toStr == "okay") {
					result["result"] = "XXX"
					result["msg"]    = err.msg.replace("sys::", "")
					result["trace"]	 = traceErr(err)
				}
			}
	
			result["dur"] = Number((Duration.now - start).floor(1ms), Unit("ms"))
			return Etc.makeDict(result)
		}
		
		return Etc.makeDictsGrid(null, results).reorderCols("result name dur msg trace".split)
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
