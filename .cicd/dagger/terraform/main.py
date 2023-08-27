import sys

import anyio
import dagger
from dagger_libs import docker


# Terraform runner
async def test_terraform_module(module: str, runner) -> None:
    initalized = await runner.with_exec(
        [
            "terraform",
            f"-chdir={module}",
            "init",
            "-get",
            "-backend=false",
            "-input=false",
        ]
    )
    await initalized.with_exec(["terraform", f"-chdir={module}", "validate"])


async def main():
    config = dagger.Config(log_output=sys.stdout)

    async with dagger.Connection(config) as client:
        terraform = (
            client.container()
            .from_("cgr.dev/chainguard/wolfi-base:latest")
            .with_directory(
                "/src",
                client.host().directory("."),
                exclude=docker.get_ignored_files(".dockerignore"),
            )
            .with_exec(["apk", "add", "--no-cache", "--update", "bash", "git", "curl"])
            .with_exec(
                [
                    "git",
                    "clone",
                    "--depth=1",
                    "https://github.com/tfutils/tfenv.git",
                    "/.tfenv",
                ]
            )
            .with_exec(["ln", "-sv", "/.tfenv/bin/terraform", "/usr/bin/terraform"])
            .with_exec(["ln", "-sv", "/.tfenv/bin/tfenv", "/usr/bin/tfenv"])
            .with_exec(
                [
                    "ln",
                    "-sv",
                    "/src/src/terraform/.terraform-version",
                    "/.tfenv/version",
                ]
            )
        )

        util = (
            client.container()
            .from_("cgr.dev/chainguard/wolfi-base:latest")
            .with_directory(
                "/src",
                client.host().directory("."),
                exclude=docker.get_ignored_files(".dockerignore"),
            )
            .with_exec(["apk", "add", "--no-cache", "--update", "bash", "git"])
        )

        # Validate Terraform formatting
        terraform_runner = terraform.with_workdir("/src")
        await terraform_runner.with_exec(
            ["terraform", "fmt", "-recursive", "-check"]
        ).sync()

        # Get a list of Terraform modules that have changed
        util_runner = util.with_workdir("/src/.cicd/utils")
        await util_runner.with_exec(["ls", "-lah"])
        stdout = await util_runner.with_exec(
            ["./terraform.sh", "get_changed_modules"]
        ).stdout()
        modules = [i.strip() for i in stdout.splitlines()]

        # Validate changed Terraform modules
        async with anyio.create_task_group() as tasks:
            for module in modules:
                tasks.start_soon(test_terraform_module, module, terraform_runner)


anyio.run(main)
