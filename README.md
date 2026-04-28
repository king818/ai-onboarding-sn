# AI Onboarding ServiceNow Reference Implementation

## Overview

This repository contains a reference implementation of a Copilot Studio onboarding assistant packaged as a Power Platform solution. It demonstrates how an AI agent can support employee onboarding workflows and integrate with ServiceNow using an enterprise-ready Application Lifecycle Management (ALM) approach.

---

## Objectives

- Provide a working Copilot-based onboarding assistant
- Illustrate onboarding workflow and data requirements
- Demonstrate ServiceNow integration concepts
- Establish a Power Platform ALM pipeline (export, unpack, version control)

---

## Solution Components

- Copilot Agent: **AI Onboarding ServiceNow Assistant**
- Topic: **Onboarding Knowledge Base**
- Power Platform Solution: `AIOnboardingSNReferenceSolution`

---

## Onboarding Workflow (Reference)

1. Offer accepted
2. Manager prepares onboarding details
3. ServiceNow requests created (IT, access, equipment)
4. Tasks tracked and updated
5. Status updates sent back to onboarding manager
6. New hire ready for Day 1

---

## Key Data Points (ServiceNow Integration)

- Employee name
- Start date
- Manager
- Department / role
- Location
- Equipment requirements
- Application access
- ServiceNow request ID
- Task status
- Completion date

---

## Integration Design

- Event-driven (asynchronous) preferred
- Avoid polling
- ServiceNow should send status updates to trigger notifications
- AI agent acts as an orchestration and guidance layer

---

## ALM Workflow

Export and import are wrapped in PowerShell scripts under `scripts/`.

### Prerequisites

- **PowerShell** — PowerShell 7+ on macOS/Linux (`pwsh`), or Windows PowerShell 5.1+ on Windows
- **Power Platform CLI** (`pac`) — install with `dotnet tool install --global Microsoft.PowerApps.CLI.Tool` or via the [official installer](https://learn.microsoft.com/power-platform/developer/cli/introduction)
- **.NET SDK** — required by `pac`

Verify with:

```powershell
pwsh --version
pac --version
dotnet --version
```

### Running the scripts

From the repo root:

**macOS / Linux**

```bash
pwsh ./scripts/export.ps1
pwsh ./scripts/import.ps1
```

**Windows (PowerShell)**

```powershell
.\scripts\export.ps1
.\scripts\import.ps1
```

If Windows blocks the script with an execution-policy error, either run it once with a bypass:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\export.ps1
```

…or allow local scripts permanently for your user:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

On the first run, each script triggers `pac auth create`, which opens a browser to sign in to your Power Platform environment. The auth profile is cached, so subsequent runs reuse it. Check active profiles with `pac auth list` and switch with `pac auth select --index <n>`.

### Parameters

Both scripts accept optional parameters (with sensible defaults):

| Parameter | Used by | Default | Description |
|---|---|---|---|
| `-SolutionName` | export | `AIOnboardingSNReferenceSolution` | Name of the solution as it appears in Power Platform |
| `-ZipPath` | export, import | `.\solution.zip` | Path to the packaged solution zip |
| `-UnpackFolder` | export, import | `.\solution` | Path to the unpacked source folder |

### Export Solution

Validates the solution exists in the current environment, exports it to a zip, then unpacks it into source-controllable form.

```powershell
# Default: exports AIOnboardingSNReferenceSolution to .\solution.zip and unpacks to .\solution
./scripts/export.ps1

# Export a different solution
./scripts/export.ps1 -SolutionName "MyOtherSolution"

# Save a dated snapshot without overwriting the working copy
./scripts/export.ps1 -ZipPath ".\backups\solution-2026-04-28.zip" -UnpackFolder ".\backups\solution-2026-04-28"
```

Wraps:

```powershell
pac solution export --name AIOnboardingSNReferenceSolution --path solution.zip --managed false
pac solution unpack --zipfile solution.zip --folder solution --packagetype Unmanaged --clobber
```

### Import Solution

Packs the source folder back into a zip, then imports and publishes it to the current environment.

```powershell
# Default: packs .\solution into .\solution.zip and imports it
./scripts/import.ps1

# Import from a specific snapshot folder
./scripts/import.ps1 -UnpackFolder ".\backups\solution-2026-04-28" -ZipPath ".\backups\solution-2026-04-28.zip"
```

Wraps:

```powershell
pac solution pack --folder solution --zipfile solution.zip --packagetype Unmanaged
pac solution import --path solution.zip --publish-changes
```

> **Heads-up:** `import.ps1` writes to whichever environment you're authenticated against. Double-check with `pac auth list` before running it.

---

## Repository Structure

```
README.md
solution.zip
solution/
  botcomponents/
  bots/
  Other/
scripts/
  export.ps1
  import.ps1
```

The `solution/` folder is what `pac solution unpack` produces. `bots/` and `botcomponents/` hold the Copilot Studio agent definition and its components; `Other/` contains solution-level metadata (`Solution.xml`, `Customizations.xml`, etc.).

---

## Environment Notes

- Copilot agent creation and solution packaging were successful
- Solution publish was successful
- Export via UI may be restricted depending on environment permissions
- CLI-based export requires:
  - Power Platform CLI (`pac`)
  - .NET SDK

---

## Next Steps

- Enable export/import permissions in a dev/sandbox environment
- Integrate the existing scripts with GitHub Actions for CI/CD
- Connect to real ServiceNow APIs

---

## Summary

This project demonstrates how to move from:

- Copilot agent design
  → Solution packaging
  → ALM readiness
  → Git-based version control

---

## Author

C.Y. Chen