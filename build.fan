using build

class Build : BuildPod {

    new make() {
        podName = "afAxontExt"
        summary = "Axon Test Runner"
        version = Version("0.0.1")

        meta = [
            "pod.dis"       : "Axont",
            "repo.public"   : "true"
        ]

        depends = [
            "sys          1.0.69 - 1.0",

            // ---- SkySpark -----------------------
            "axon         3.0.12  - 3.0",
            "haystack     3.0.12  - 3.0",
            "skyarcd      3.0.12  - 3.0",
        ]

        srcDirs = [`fan/`]
        resDirs = [`lib/`]

        docApi = true
        docSrc = false
        meta["afBuild.docApi"]  = "true"
        meta["afBuild.docSrc"]  = "true"

        meta["afBuild.testPods"]    = ""
        meta["afBuild.testDirs"]    = "lib/"

		index = [
			"skyarc.ext": "afAxontExt::AxontExt",
			"skyarc.lib": "afAxontExt::AxontLib",
		]
    }
}
