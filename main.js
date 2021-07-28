const core = require("@actions/core")
const exec = require("@actions/exec")
const firstline = require("firstline")
const hub = require("docker-hub-utils")
const path = require("path")
const fs = require("fs")

async function main() {
    try {
        let container = "deb-builder";

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

        core.startGroup("Create container")
        await exec.exec("docker", [
            "create",
            "--name", container,
            "--volume", sourceDirectory + ":/src",
            "--workdir=/src",
            "--volume", buildDirectory + ":/build",
            "--tty",
            "--env", "DEBUG=" + DEBUG,
            "--env", "INSTALL_BUILD_DEPS=" + INSTALL_BUILD_DEPS,
            "--env", "BUILD=" + BUILD,
            "--env", "CHECK=" + CHECK,
            "--env", "DPKG_BUILDPACKAGE_CHECK_BUILDDEPS=" + DPKG_BUILDPACKAGE_CHECK_BUILDDEPS,
            "--env", "DPKG_BUILDPACKAGE_POST_CLEAN=" + DPKG_BUILDPACKAGE_POST_CLEAN,
            "--env", "LINTIAN_DONT_CHECK_PARTS=" + LINTIAN_DONT_CHECK_PARTS,
            "--env", "LINTIAN_TAGS_TO_SUPPRESS=" + LINTIAN_TAGS_TO_SUPPRESS,
            "--env", "LINTIAN_DISPLAY_INFO=" + LINTIAN_DISPLAY_INFO,
            "--env", "LINTIAN_SHOW_OVERRIDES=" + LINTIAN_SHOW_OVERRIDES,
            "--env", "LINTIAN_TAG_DISPLAY_LIMIT=" + LINTIAN_TAG_DISPLAY_LIMIT,
            "--env", "LINTIAN_FAIL_ON_ERROR=" + LINTIAN_FAIL_ON_ERROR,
            "--env", "LINTIAN_FAIL_ON_WARNING=" + LINTIAN_FAIL_ON_WARNING,
            "--env", "LINTIAN_FAIL_ON_INFO=" + LINTIAN_FAIL_ON_INFO,
            "--env", "LINTIAN_FAIL_ON_PEDANTIC=" + LINTIAN_FAIL_ON_PEDANTIC,
            "--env", "LINTIAN_FAIL_ON_EXPERIMENTAL=" + LINTIAN_FAIL_ON_EXPERIMENTAL,
            "--env", "LINTIAN_FAIL_ON_OVERRIDE=" + LINTIAN_FAIL_ON_OVERRIDE,
            "--env", "LINTIAN_NO_FAIL=" + LINTIAN_NO_FAIL,
            "--env", "DPKG_BUILDPACKAGE_OPTS=" + DPKG_BUILDPACKAGE_OPTS,
            "--env", "LINTIAN_OPTS=" + LINTIAN_OPTS,
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


            // TODO: 
                // # Get dev packages from backports if available
                // backports_list_file="/etc/apt/sources.list.d/backports.list"
                // if [[ -f "${backports_list_file}" ]]; then
                //   backports_repo_name="$(awk '{print $3}' "${backports_list_file}")"
                //   apt_get_install_opts="${apt_get_install_opts} -t ${backports_repo_name}"
                // fi

            // e.g. 'buster-backports' vs 'bullseye'
            includeBackports = DEBIAN_BASE_IMAGE.includes("-");
            backportsOpts = includeBackports ? ["-t", DEBIAN_BASE_IMAGE] : [];
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
                "bash", "-x", "/check-deb"
            ])
            core.endGroup()
        }


    } catch (error) {
        core.setFailed(error.message)
    }
}

main()
