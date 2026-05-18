---
description: Install a skill by name or owner/repo path. Use when the user says "install skill X", "add skill X", "スキルをインストールして", "スキルを追加して", or provides a skill package path like "owner/repo skill-name".
metadata:
    argument-hint: <skill-name or owner/repo skill-name>
    author: kmuto
    version: 1.0.0
name: add-skill
---
# Add Skill

Install a skill into Claude Code using `gh skill install`.

## When to Use This Skill

Use this skill when the user:

- Says "install skill X" or "add skill X"
- Says "スキルをインストールして" or "スキルを追加して"
- Provides a skill package path like `vercel-labs/agent-skills web-design-guidelines`
- Wants to install a specific skill they already know the name of

## How It Works

### Step 1: Resolve the skill package path

If the user provided a full `owner/repo skill-name` pair, use it directly.

If only a skill name is given (e.g. `remotion-best-practices`), fetch the leaderboard to find the correct owner/repo:

```
https://skills.sh/
```

Search for the skill name in the leaderboard results and extract the `owner/repo` and `skill-name`.

### Step 2: Install the skill

Run the following command (sandbox must be disabled for GitHub API access):

```bash
gh skill install --scope user --agent claude-code <owner/repo> <skill-name>
```

- `--scope user` installs globally for the current user (available in all projects)
- `--agent claude-code` targets Claude Code specifically

### Step 3: Confirm installation

After installation, confirm:
1. The skill name and version installed
2. The install location (`~/.claude/skills/<skill-name>/`)
3. How to invoke it (trigger phrases)

### Step 4: Warn about security

Always remind the user that skills are not verified by GitHub and may contain prompt injections. Recommend reviewing the installed `SKILL.md` before use, especially for skills from unknown authors.

## Example Interactions

**Full path provided:**
> "install vercel-labs/agent-skills vercel-react-best-practices"
→ Run: `gh skill install --scope user --agent claude-code vercel-labs/agent-skills vercel-react-best-practices`

**Only skill name provided:**
> "install remotion-best-practices"
→ Fetch skills.sh leaderboard → find `remotion-dev/skills` → Run install

**Japanese input:**
> "web-design-guidelinesをインストールして"
→ Fetch skills.sh leaderboard → find `vercel-labs/agent-skills` → Run install

## Error Handling

- If the skill is not found on skills.sh, inform the user and suggest using `/find-skills` to search
- If installation fails due to network issues, the `gh` command requires sandbox to be disabled — retry with `dangerouslyDisableSandbox: true`
- If the skill is already installed, inform the user and offer to update with `gh skill upgrade --scope user --agent claude-code <owner/repo> <skill-name>`
