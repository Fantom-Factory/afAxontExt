using axon::Fn
using axon::EvalErr
using axon::Loc
using haystack::Etc
using haystack::Ref
using haystack::Marker
using skyarcd::Context
using skyarcd::Proj
using skyarc::User

internal class AxontRunner {
	
	private Loc?		loc
	private [Str:Obj?]?	vars
	private Context?	axonCtx
	
	** Runs the given fn in the context of a new SkySpark project.
	** The fn may call 'callAxonFn()'.
	Obj? runInTestProj(|AxontRunner->Obj?| fn) {
		if (axonCtx != null)
			throw Err("Could not runInTestProj - this instance may only be used once")

		loc			 = Loc("afAxontExt.runInTestProj")
		curCtx		:= Context.cur(true)
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

		// dup() is VERY important - it prevents SkySpark from adding more vars to it! :)
		vars		 = curCtx->stack->get(-2)->vars->dup
	
		// try to put the proj into a steady state, as per ProjTest.forceSteadyState()
		try proj->testForceSteadyState
		catch (Err err) { proj.log.warn("Could not force steady state - ${err.msg}") }

		try {
			suUser	:= makeSyntheticUser("axontTestUser", "su")
			axonCtx  = Context.make(curCtx.sys, suUser, proj)
			return fn(this)
		}
		finally projDelFn.callx(curCtx, [Ref("p:${projName}"), Date.today.toIso], loc)
	}
	
	** Calls the given Axon Fn (or fn name) in the context of the new project.
	Obj? callAxonFn(Obj? axonObj, Obj?[]? args := null) {
		if (axonObj == null)
			return null

		axonFn := (axonObj as Fn) ?: axonCtx.findTop(axonObj.toStr, false)
		if (axonFn == null)
			throw Err("Unknown func: ${axonObj}")

		return axonCtx.callInNewFrame(axonFn, args ?: Obj#.emptyList, loc, vars)
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
}
