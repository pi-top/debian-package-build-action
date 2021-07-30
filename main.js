const core = require("@actions/core")
const exec = require("@actions/exec")
const firstline = require("firstline")
const hub = require("docker-hub-utils")
const path = require("path")
const fs = require("fs")

async function main() {
    try {
        let container = "deb-builder";

        const buildEnvStr = core.getInput("build_env") || ""
        const buildEnvList = buildEnvStr.split("\n").filter(x => x !== "")

        const dockerImage = core.getInput("docker_image") || "debian:stable"
        const sourceRelativeDirectory = core.getInput("source_directory")
        const buildRelativeDirectory = core.getInput("build_directory") || "/tmp/artifacts/bin"
        const targetArchitecture = core.getInput("target_architecture") || "amd64"

        const workspaceDirectory = process.cwd()
        const sourceDirectory = path.join(workspaceDirectory, sourceRelativeDirectory)
        const buildDirectory = path.join(workspaceDirectory, buildRelativeDirectory)

        // Stages - boolean
        const DEBUG = core.getInput("DEBUG") || "0"
        const INSTALL_BUILD_DEPS = core.getInput("INSTALL_BUILD_DEPS") || "1"
        const INSTALL_DEPS = core.getInput("INSTALL_DEPS") || "1"
        const BUILD = core.getInput("BUILD") || "1"
        const CHECK = core.getInput("CHECK") || "1"
        // Build configuration
        const DPKG_BUILDPACKAGE_CHECK_BUILDDEPS = core.getInput("DPKG_BUILDPACKAGE_CHECK_BUILDDEPS") || "0"
        const DPKG_BUILDPACKAGE_POST_CLEAN = core.getInput("DPKG_BUILDPACKAGE_POST_CLEAN") || "0"
        // Quality check configuration - comma-separated lists
        const LINTIAN_DONT_CHECK_PARTS = core.getInput("LINTIAN_DONT_CHECK_PARTS") || "nmu"
        const LINTIAN_TAGS_TO_SUPPRESS = core.getInput("LINTIAN_TAGS_TO_SUPPRESS") || "initial-upload-closes-no-bugs,debian-watch-file-is-missing"
        // Quality check configuration - boolean
        const LINTIAN_DISPLAY_INFO = core.getInput("LINTIAN_DISPLAY_INFO") || "1"
        const LINTIAN_SHOW_OVERRIDES = core.getInput("LINTIAN_SHOW_OVERRIDES") || "1"
        const LINTIAN_TAG_DISPLAY_LIMIT = core.getInput("LINTIAN_TAG_DISPLAY_LIMIT") || "0"
        // LINTIAN_NO_FAIL overrides all others
        const LINTIAN_FAIL_ON_ERROR = core.getInput("LINTIAN_FAIL_ON_ERROR") || "1"
        const LINTIAN_FAIL_ON_WARNING = core.getInput("LINTIAN_FAIL_ON_WARNING") || "1"
        const LINTIAN_FAIL_ON_INFO = core.getInput("LINTIAN_FAIL_ON_INFO") || "0"
        const LINTIAN_FAIL_ON_PEDANTIC = core.getInput("LINTIAN_FAIL_ON_PEDANTIC") || "0"
        const LINTIAN_FAIL_ON_EXPERIMENTAL = core.getInput("LINTIAN_FAIL_ON_EXPERIMENTAL") || "0"
        const LINTIAN_FAIL_ON_OVERRIDE = core.getInput("LINTIAN_FAIL_ON_OVERRIDE") || "0"
        const LINTIAN_NO_FAIL = core.getInput("LINTIAN_NO_FAIL") || "0"
        // Additional options
        const DPKG_BUILDPACKAGE_OPTS = core.getInput("DPKG_BUILDPACKAGE_OPTS") || ""
        const LINTIAN_OPTS = core.getInput("LINTIAN_OPTS") || ""
        
        core.startGroup("Print details")
        const details = {
            dockerImage: dockerImage ,
            sourceDirectory: sourceDirectory ,
            buildDirectory: buildDirectory,
            targetArchitecture: targetArchitecture,
            DEBUG: DEBUG,
            INSTALL_BUILD_DEPS: INSTALL_BUILD_DEPS,
            BUILD: BUILD,
            CHECK: CHECK,
            DPKG_BUILDPACKAGE_CHECK_BUILDDEPS: DPKG_BUILDPACKAGE_CHECK_BUILDDEPS,
            DPKG_BUILDPACKAGE_POST_CLEAN: DPKG_BUILDPACKAGE_POST_CLEAN,
            LINTIAN_DONT_CHECK_PARTS: LINTIAN_DONT_CHECK_PARTS,
            LINTIAN_TAGS_TO_SUPPRESS: LINTIAN_TAGS_TO_SUPPRESS,
            LINTIAN_DISPLAY_INFO: LINTIAN_DISPLAY_INFO,
            LINTIAN_SHOW_OVERRIDES: LINTIAN_SHOW_OVERRIDES,
            LINTIAN_TAG_DISPLAY_LIMIT: LINTIAN_TAG_DISPLAY_LIMIT,
            LINTIAN_FAIL_ON_ERROR: LINTIAN_FAIL_ON_ERROR,
            LINTIAN_FAIL_ON_WARNING: LINTIAN_FAIL_ON_WARNING,
            LINTIAN_FAIL_ON_INFO: LINTIAN_FAIL_ON_INFO,
            LINTIAN_FAIL_ON_PEDANTIC: LINTIAN_FAIL_ON_PEDANTIC,
            LINTIAN_FAIL_ON_EXPERIMENTAL: LINTIAN_FAIL_ON_EXPERIMENTAL,
            LINTIAN_FAIL_ON_OVERRIDE: LINTIAN_FAIL_ON_OVERRIDE,
            LINTIAN_NO_FAIL: LINTIAN_NO_FAIL,
            DPKG_BUILDPACKAGE_OPTS: DPKG_BUILDPACKAGE_OPTS,
            LINTIAN_OPTS: LINTIAN_OPTS,
        }
        console.log(details)
        core.endGroup()

        let platform = "linux/amd64";
        if (targetArchitecture !== "amd64") {
            core.startGroup("Package requires emulation - starting tonistiigi/binfmt")
            platform = "linux/arm/v7";
            await exec.exec("docker", [
                "run",
                "--rm",
                "--privileged",
                "tonistiigi/binfmt",
                "--install",
                "all",
            ])
            core.endGroup()
        }


        core.startGroup("Create container")

        envOpts = Array()
        buildEnvList.map(buildEnvVar => {envOpts.push("--env"); envOpts.push(buildEnvVar)});

        envOpts.push("--env").push("DEBUG=" + DEBUG)
        envOpts.push("--env").push("INSTALL_BUILD_DEPS=" + INSTALL_BUILD_DEPS)
        envOpts.push("--env").push("BUILD=" + BUILD)
        envOpts.push("--env").push("CHECK=" + CHECK)
        envOpts.push("--env").push("DPKG_BUILDPACKAGE_CHECK_BUILDDEPS=" + DPKG_BUILDPACKAGE_CHECK_BUILDDEPS)
        envOpts.push("--env").push("DPKG_BUILDPACKAGE_POST_CLEAN=" + DPKG_BUILDPACKAGE_POST_CLEAN)
        envOpts.push("--env").push("LINTIAN_DONT_CHECK_PARTS=" + LINTIAN_DONT_CHECK_PARTS)
        envOpts.push("--env").push("LINTIAN_TAGS_TO_SUPPRESS=" + LINTIAN_TAGS_TO_SUPPRESS)
        envOpts.push("--env").push("LINTIAN_DISPLAY_INFO=" + LINTIAN_DISPLAY_INFO)
        envOpts.push("--env").push("LINTIAN_SHOW_OVERRIDES=" + LINTIAN_SHOW_OVERRIDES)
        envOpts.push("--env").push("LINTIAN_TAG_DISPLAY_LIMIT=" + LINTIAN_TAG_DISPLAY_LIMIT)
        envOpts.push("--env").push("LINTIAN_FAIL_ON_ERROR=" + LINTIAN_FAIL_ON_ERROR)
        envOpts.push("--env").push("LINTIAN_FAIL_ON_WARNING=" + LINTIAN_FAIL_ON_WARNING)
        envOpts.push("--env").push("LINTIAN_FAIL_ON_INFO=" + LINTIAN_FAIL_ON_INFO)
        envOpts.push("--env").push("LINTIAN_FAIL_ON_PEDANTIC=" + LINTIAN_FAIL_ON_PEDANTIC)
        envOpts.push("--env").push("LINTIAN_FAIL_ON_EXPERIMENTAL=" + LINTIAN_FAIL_ON_EXPERIMENTAL)
        envOpts.push("--env").push("LINTIAN_FAIL_ON_OVERRIDE=" + LINTIAN_FAIL_ON_OVERRIDE)
        envOpts.push("--env").push("LINTIAN_NO_FAIL=" + LINTIAN_NO_FAIL)
        envOpts.push("--env").push("DPKG_BUILDPACKAGE_OPTS=" + DPKG_BUILDPACKAGE_OPTS)
        envOpts.push("--env").push("LINTIAN_OPTS=" + LINTIAN_OPTS)

        await exec.exec("docker", [
            "create",
            "--name", container,
            "--volume", sourceDirectory + ":/src",
            "--workdir=/src",
            "--volume", buildDirectory + ":/build",
            "--tty",
            ...envOpts,
            "--platform", platform,
            dockerImage,
            "sleep", "inf"
        ])
        core.endGroup()
        
        core.startGroup("Start container")
        await exec.exec("docker", [
            "start",
            container
        ])
        core.saveState("container", container)
        core.endGroup()

        if (INSTALL_DEPS) {
            core.startGroup("Installing dependencies")
            await exec.exec("docker", [
                "exec",
                container,
                "sudo",
                "apt-get",
                "update",
            ])
            await exec.exec("docker", [
                "exec",
                container,
                "sudo",
                "apt-get",
                "upgrade",
                "-y",
            ])

            let backportsListStdout = "";
            const backportsListOpts = {}
            backportsListOpts.listeners = {
                stdout: (data) => {
                    backportsListStdout += data.toString();
                },
                ignoreReturnCode: true,
            }
            backportsListFile="/etc/apt/sources.list.d/backports.list";
            await exec.exec("docker", [
                "exec",
                container,
                "cat",
                backportsListFile
            ], backportsListOpts)

            backportsOpts = [];
            if (backportsListStdout !== "") {
                backportsOpts = ["-t", backportsListStdout.trim().split(" ")[2]];
            }

            await exec.exec("docker", [
                "exec",
                container,
                "sudo",
                "apt-get",
                "-y",
                "install",
                "--no-install-recommends",
                ...backportsOpts,
                "debhelper",
                "devscripts",
                "dpkg-dev",
                "fakeroot",
                "lintian",
                "sudo"
            ])
            core.endGroup()
        }

        if (INSTALL_BUILD_DEPS) {
            core.startGroup("Installing package build dependencies")
            await exec.exec("docker", [
                "exec",
                container,
                "sudo",
                "apt-get",
                "build-dep",
                "-y",
                ".",
            ])
            core.endGroup()
        }

        if (BUILD) {
            core.startGroup("Building Debian package")
            await exec.exec("docker", [
                "exec",
                container,
                "/build-deb"
            ])
            core.endGroup()
        }

        if (CHECK) {
            core.startGroup("Checking packages")
            await exec.exec("docker", [
                "exec",
                container,
                "/check-deb"
            ])
            core.endGroup()
        }


    } catch (error) {
        core.setFailed(error.message)
    }
}

main()
