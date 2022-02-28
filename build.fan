using build

class Build : BuildPod {

	new make() {
		podName = "afAxontExt"
		summary = "Unit test runner and assertion functions for Axon"
		version = Version("0.1.0")

		meta = [
			"pod.dis"		: "Axont",
			"pod.uri"		: "https://stackhub.org/package/afAxontExt",
			"repo.public"	: "true",
			"skyarc.icons"	: "true",
		]

		depends = [
			"sys        1.0.77 - 1.0",

			// ---- SkySpark -----------------------
			"axon       3.1.1  - 3.1",
			"haystack   3.1.1  - 3.1",
			"skyarc     3.1.1  - 3.1",
			"skyarcd    3.1.1  - 3.1",
		]

		srcDirs = [`fan/`, `test/`]
		resDirs = [`doc/`, `lib/`, `svg/`]

		docApi = true
		docSrc = false
		meta["afBuild.docApi"]  = "true"
		meta["afBuild.docSrc"]  = "true"

		meta["afBuild.testPods"]		= ""
		meta["afBuild.testDirs"]		= "test/ lib/"
		meta["afBuild.plainReadmeMd"]	= "true"
		//meta["afBuild.skipReadmeMd"]	= "true"

		index = [
			"skyarc.ext": "afAxontExt::AxontExt",
			"skyarc.lib": "afAxontExt::AxontLib",
		]
	}
}
