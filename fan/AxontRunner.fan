using axon::Fn
using axon::EvalErr
using axon::Loc
using axon::CoreLib
using haystack::Etc
using haystack::Ref
using haystack::Dict
using haystack::Marker
using haystack::Symbol
using skyarcd::Context
using skyarcd::Proj
using skyarc::User
using skyarc::ExtDef
using hx::HxCoreFuncs
using folio::Diff

internal class AxontRunner {
	
	private Loc?		loc
	private [Str:Obj?]?	vars
	private Context?	axonCtx
	private	Str[]?		exts
	private	Str?		recs
	
	new make(Dict opts) {
		this.exts = opts.get("exts")
		this.recs = opts.get("recs")
		
		// default to enabling all the exts in the current Proj
		if (exts == null)
			exts = Context.cur(true).proj.extStatus
				.findAll |row| { row.has("enabled") }
				.colToList("name", Str#)
		
		// default to copying over funcs and defs
		if (recs == null)
			recs = "func or def"
	}
	
	** Runs the given fn in the context of a new SkySpark project.
	** The fn may call 'callAxonFn()'.
	Obj? runInNewProj(|AxontRunner->Obj?| fn) {
		if (axonCtx != null)
			throw Err("Could not runInTestProj - this instance may only be used once")

		// dup() is VERY important - it prevents SkySpark from adding more vars to it! :)
		curCtx		:= Context.cur(true)
		projNewFn	:= curCtx.findTop("projNew")		// projMod::StdProjLib.projNew()
		projDelFn	:= curCtx.findTop("projDelete")		// projMod::StdProjLib.projDelete()
		vars		 = curCtx->stack->get(-2)->vars->dup
		loc			 = Loc("afAxontExt.runInTestProj")
		
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

		// add extensions - making sure to add them in the order of depends
		sortExtsViaDepends(proj, exts).each |def| {
			proj.extAdd(def)
		}
	
		// copy over recs
		recGrid := CoreLib.swizzleRefs(curCtx.readAll(recs))
		recDict := HxCoreFuncs.stripUncommittable(recGrid) as Dict[]
		recDiff := recDict.map |row| {
			id := row.get("id")
			row = Etc.dictRemove(row, "id")
			return Diff.makeAdd(row, id)
		}
		proj.commitAll(recDiff)

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
	
	private static ExtDef[] sortExtsViaDepends(Proj proj, Str[] exts) {
		
		// remove those exts that come enabled by default
		proj.extStatus.each |row| {
			if (row.has("enabled"))
				exts.remove(row.get("name"))
		}
		
		defs := (ExtDef[]) exts.map { proj.sys.ext(it) }

		defs.sort |d1, d2| {
			d1Sym := Symbol("lib:${d1.name}")
			d2Sym := Symbol("lib:${d2.name}")

			if (d1.depends.contains(d2Sym))	return 1
			if (d2.depends.contains(d1Sym))	return -1
			return 0
		}

		return defs
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
