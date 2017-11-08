using build

class Build : BuildPod {

    new make() {
        podName = "afAxontExt"
        summary = "Test runner and assertion functions for Axon"
        version = Version("0.0.6")

        meta = [
            "pod.dis"       : "Axont",
			"pod.uri"		: "https://stackhub.org/package/afAxontExt",
            "repo.public"   : "true",
			"skyarc.icons"	: "true",
        ]

        depends = [
            "sys          1.0.69 - 1.0",

            // ---- SkySpark -----------------------
            "axon         3.0.12  - 3.0",
            "haystack     3.0.12  - 3.0",
            "skyarc       3.0.12  - 3.0",
            "skyarcd      3.0.12  - 3.0",
        ]

        srcDirs = [`fan/`]
        resDirs = [`doc/`, `lib/`, `svg/`]

        docApi = true
        docSrc = false
		meta["afBuild.docApi"]  = "true"
        meta["afBuild.docSrc"]  = "true"

        meta["afBuild.testPods"]    	= ""
        meta["afBuild.testDirs"]    	= "lib/"
        meta["afBuild.plainReadmeMd"]	= "true"
        //meta["afBuild.skipReadmeMd"]	= "true"

		index = [
			"skyarc.ext": "afAxontExt::AxontExt",
			"skyarc.lib": "afAxontExt::AxontLib",
		]
    }
}
