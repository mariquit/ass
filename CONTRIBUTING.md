# Contributing to Agent Skills for Software Engineering

This project collects agent skills for Claude Code and OpenCode. Contributions should help agents make better decisions without prescribing every implementation detail.

## Code of Conduct

Treat contributors with respect. Keep feedback constructive and focused on the proposed change.

## Project Overview

Contributions generally involve three connected areas:

- **Skill guidance:** The eight root skill files cover architecture decisions (`adr.md`), prose editing (`de-slop.md`), knowledge capture (`deconstruct.md`), frontend development (`frontend.md`), change review (`pre-flight.md`), regression testing (`regression-test.md`), concise execution (`terse.md`), and debugging (`triage.md`). Each contains YAML frontmatter for discovery and instructions loaded when the skill is used. Improve the relevant skill without expanding its scope unnecessarily.
- **Discoverability:** `README.md` explains when to use each skill through the overview and SDLC mapping. Keep these descriptions aligned with changes to skill names or behavior.
- **Deployment:** `Makefile` copies the skills in its `SKILLS` list into Claude Code and OpenCode skill directories as `<skill>/SKILL.md`. New skills should be included in that list when ready for deployment.

## Local Setup and Checks

Use Git and a text editor to make documentation changes. Deployment uses GNU Make and standard shell utilities; no Python setup is required.

Review the changed Markdown and YAML frontmatter, then check for whitespace errors:

```bash
git diff --check
```

For behavior changes, try the skill on a representative task when possible. Record the agent environment, relevant input, expected behavior, and observed result. State which checks you could not perform.

Run `make deploy` (or `make deploy-skill`) from the repository root to install all eight skills. Plain `make` performs the same deployment. The default destinations are `~/.claude/skills` and `~/.config/opencode/skills`; override `CLAUDE_SKILLS_DIR` and `OPENCODE_SKILLS_DIR` to use different directories.

Deployment replaces matching installed `SKILL.md` files. It does not change client settings or install output styles. Existing output styles from older deployments are left untouched. To test deployment without changing your agent configuration, use temporary destination directories, for example:

```bash
make deploy CLAUDE_SKILLS_DIR="$test_dir/claude" OPENCODE_SKILLS_DIR="$test_dir/opencode"
```

Set `test_dir` to an isolated temporary directory first. Compare installed files with their sources; copying successfully does not establish that a skill behaves correctly in an agent session.

## Skill-Writing Guidelines

- Keep each skill focused on its purpose. Prefer useful defaults and clear boundaries over exhaustive rules or approval gates.
- Preserve existing project conventions and user work. Do not turn guidance into permission for unrelated changes.
- Keep examples accurate and distinguish verified behavior from assumptions. Do not claim support for untested tools or environments.
- Use `license: MIT` and `metadata.copyright` in skill frontmatter, following the existing files. Preserve applicable third-party license and attribution notices; do not add material you lack permission to contribute.
- When adding or renaming a skill, update the README overview and relevant SDLC mapping. Update the Makefile's skill list if the skill should be included in deployment.

## How to Contribute

### Reporting Problems

Check existing issues before opening a report. Include the affected skill, the relevant instructions or input, expected behavior, and actual behavior. For agent-specific problems, include the client and model versions when known. Remove secrets and private project data from examples.

### Pull Requests

1. Create a branch and keep the change focused on one improvement or fix.
2. Update related documentation or examples where the change requires it.
3. Review the diff and perform relevant checks or representative task trials.
4. Describe the problem, the change, and validation results in the pull request. Identify any remaining verification gaps.

## License

Contributions are provided under the project's [MIT License](./LICENSE). Ensure you have the necessary rights to contribute the material and retain any applicable third-party notices.
