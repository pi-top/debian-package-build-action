const core = require("@actions/core")
const exec = require("@actions/exec")
const firstline = require("firstline")
const hub = require("docker-hub-utils")
const path = require("path")
const fs = require("fs")

async function main() {
    try {
        let container = "deb-builder";

        // Parse additional_env string of multiple VAR=value statements into array of such statements buildEnvList
        // Supports newlines in values but will treat each line starting VAR= as a new declaration
        let buildEnvList = []
        const additionalEnv = core.getInput("additional_env")
        const buildEnvNames = additionalEnv.match(/^\w+=/gm)
        if (buildEnvNames) {
          const buildEnvValues = (additionalEnv + '\n')
            .split(/^\w+=/gm).slice(1)
            .map(s => s.replace(/\n$/, ''))
          buildEnvList = buildEnvNames.map((n, i) => `${n}${buildEnvValues[i]}`)
        }

        const dockerImage = core.getInput("docker_image") || "debian:stable"
        const sourceRelativeDirectory = core.getInput("source_directory")
        const buildRelativeDirectory = core.getInput("build_directory") || "/tmp/artifacts/bin"
        const targetArchitecture = core.getInput("target_architecture") || "amd64"

        const workspaceDirectory = process.cwd()
        const sourceDirectory = path.join(workspaceDirectory, sourceRelativeDirectory)
        const buildDirectory = path.join(workspaceDirectory, buildRelativeDirectory)

        // Stages - boolean
        const debug = core.getInput("debug") || "0"
        const installBuildDeps = core.getInput("install_build_deps") || "1"
        const installDeps = core.getInput("install_deps") || "1"
        const build = core.getInput("build") || "1"
        const check = core.getInput("check") || "1"
        // Build configuration
        const signingKey = core.getInput("signing_key") || ""
        const signingPassphrase = core.getInput("signing_passphrase") || ""
        const dpkg_buildpackage_include_debug_package = core.getInput("dpkg_buildpackage_include_debug_package") || "0"
        const dpkg_buildpackage_harden_all = core.getInput("dpkg_buildpackage_harden_all") || "0"
        const dpkg_buildpackage_force_include_source = core.getInput("dpkg_buildpackage_force_include_source") || "0"
        const dpkg_buildpackage_check_builddeps = core.getInput("dpkg_buildpackage_check_builddeps") || "0"
        const dpkg_buildpackage_post_clean = core.getInput("dpkg_buildpackage_post_clean") || "0"
        // Quality check configuration - comma-separated lists
        const lintian_dont_check_parts = core.getInput("lintian_dont_check_parts") || "nmu"
        const lintian_tags_to_suppress = core.getInput("lintian_tags_to_suppress") || ""
        const lintian_check_changelog_spelling = core.getInput("lintian_check_changelog_spelling") || "1"
        const lintian_check_itp_bug = core.getInput("lintian_check_itp_bug") || "0"
        const lintian_check_watch_file = core.getInput("lintian_check_watch_file") || "0"

        // Quality check configuration - boolean
        const lintian_display_info = core.getInput("lintian_display_info") || "1"
        const lintian_show_overrides = core.getInput("lintian_show_overrides") || "1"
        const lintian_tag_display_limit = core.getInput("lintian_tag_display_limit") || "0"
        // lintian_no_fail overrides all others
        const lintian_fail_on_error = core.getInput("lintian_fail_on_error") || "1"
        const lintian_fail_on_warning = core.getInput("lintian_fail_on_warning") || "1"
        const lintian_fail_on_info = core.getInput("lintian_fail_on_info") || "0"
        const lintian_fail_on_pedantic = core.getInput("lintian_fail_on_pedantic") || "0"
        const lintian_fail_on_experimental = core.getInput("lintian_fail_on_experimental") || "0"
        const lintian_fail_on_override = core.getInput("lintian_fail_on_override") || "0"
        const lintian_no_fail = core.getInput("lintian_no_fail") || "0"
        // Additional options
        const dpkg_buildpackage_opts = core.getInput("dpkg_buildpackage_opts") || ""
        const lintian_opts = core.getInput("lintian_opts") || ""

        core.startGroup("Print details")
        const details = {
            dockerImage: dockerImage,
            sourceDirectory: sourceDirectory,
            buildDirectory: buildDirectory,
            targetArchitecture: targetArchitecture,
            debug: debug,
            installBuildDeps: installBuildDeps,
            build: build,
            check: check,
            dpkg_buildpackage_include_debug_package: dpkg_buildpackage_include_debug_package,
            dpkg_buildpackage_harden_all: dpkg_buildpackage_harden_all,
            dpkg_buildpackage_force_include_source: dpkg_buildpackage_force_include_source,
            dpkg_buildpackage_check_builddeps: dpkg_buildpackage_check_builddeps,
            dpkg_buildpackage_post_clean: dpkg_buildpackage_post_clean,
            lintian_dont_check_parts: lintian_dont_check_parts,
            lintian_tags_to_suppress: lintian_tags_to_suppress,
            lintian_check_changelog_spelling: lintian_check_changelog_spelling,
            lintian_check_itp_bug: lintian_check_itp_bug,
            lintian_check_watch_file: lintian_check_watch_file,
            lintian_display_info: lintian_display_info,
            lintian_show_overrides: lintian_show_overrides,
            lintian_tag_display_limit: lintian_tag_display_limit,
            lintian_fail_on_error: lintian_fail_on_error,
            lintian_fail_on_warning: lintian_fail_on_warning,
            lintian_fail_on_info: lintian_fail_on_info,
            lintian_fail_on_pedantic: lintian_fail_on_pedantic,
            lintian_fail_on_experimental: lintian_fail_on_experimental,
            lintian_fail_on_override: lintian_fail_on_override,
            lintian_no_fail: lintian_no_fail,
            dpkg_buildpackage_opts: dpkg_buildpackage_opts,
            lintian_opts: lintian_opts,
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

        const envs = [
          ...buildEnvList,
          "DEBUG=" + debug,
          "INSTALL_BUILD_DEPS=" + installBuildDeps,
          "BUILD=" + build,
          "CHECK=" + check,
          "SIGNING_KEY=" + signingKey,
          "SIGNING_PASSPHRASE=" + signingPassphrase,
          "DPKG_BUILDPACKAGE_INCLUDE_DEBUG_PACKAGE=" + dpkg_buildpackage_include_debug_package,
          "DPKG_BUILDPACKAGE_HARDEN_ALL=" + dpkg_buildpackage_harden_all,
          "DPKG_BUILDPACKAGE_FORCE_INCLUDE_SOURCE=" + dpkg_buildpackage_force_include_source,
          "DPKG_BUILDPACKAGE_CHECK_BUILDDEPS=" + dpkg_buildpackage_check_builddeps,
          "DPKG_BUILDPACKAGE_POST_CLEAN=" + dpkg_buildpackage_post_clean,
          "LINTIAN_DONT_CHECK_PARTS=" + lintian_dont_check_parts,
          "LINTIAN_TAGS_TO_SUPPRESS=" + lintian_tags_to_suppress,
          "LINTIAN_CHECK_CHANGELOG_SPELLING=" + lintian_check_changelog_spelling,
          "LINTIAN_CHECK_ITP_BUG=" + lintian_check_itp_bug,
          "LINTIAN_CHECK_WATCH_FILE=" + lintian_check_watch_file,
          "LINTIAN_DISPLAY_INFO=" + lintian_display_info,
          "LINTIAN_SHOW_OVERRIDES=" + lintian_show_overrides,
          "LINTIAN_TAG_DISPLAY_LIMIT=" + lintian_tag_display_limit,
          "LINTIAN_FAIL_ON_ERROR=" + lintian_fail_on_error,
          "LINTIAN_FAIL_ON_WARNING=" + lintian_fail_on_warning,
          "LINTIAN_FAIL_ON_INFO=" + lintian_fail_on_info,
          "LINTIAN_FAIL_ON_PEDANTIC=" + lintian_fail_on_pedantic,
          "LINTIAN_FAIL_ON_EXPERIMENTAL=" + lintian_fail_on_experimental,
          "LINTIAN_FAIL_ON_OVERRIDE=" + lintian_fail_on_override,
          "LINTIAN_NO_FAIL=" + lintian_no_fail,
          "DPKG_BUILDPACKAGE_OPTS=" + dpkg_buildpackage_opts,
          "LINTIAN_OPTS=" + lintian_opts,
        ]
        const envOpts = envs.reduce((opts, env) => [...opts, "--env", env], [])

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

        core.startGroup("Print env")
        await exec.exec("docker", [
            "exec",
            container,
            "env"
        ])
        core.endGroup()

        if (installDeps) {
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
                "sudo", "apt-get", "upgrade","-y",
            ])

            let backportsListStdout = "";
            const backportsListOpts = {};
            backportsListOpts.ignoreReturnCode = true;
            backportsListOpts.listeners = {
                stdout: (data) => {
                    backportsListStdout += data.toString();
                }
            }
            await exec.exec("docker", [
                "exec",
                container,
                "cat", "/etc/apt/sources.list.d/backports.list",
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

        if (installBuildDeps) {
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

        if (build) {
            core.startGroup("Building Debian package")
            await exec.exec("docker", [
                "exec",
                container,
                "/build-deb"
            ])
            core.endGroup()
        }

        if (check) {
            core.startGroup("Checking packages")
            await exec.exec("docker", [
                "exec",
                container,
                "/check-deb"
            ])
            core.endGroup()
        }

        if (signingKey) {
            core.startGroup("Signing packages")
            await exec.exec("docker", [
                "exec",
                container,
                "/sign-deb"
            ])
            core.endGroup()
        }
    } catch (error) {
        core.setFailed(error.message)
    }
}

main()
