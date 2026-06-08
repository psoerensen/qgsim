# Collaborator workflow with GitHub Desktop and RStudio

This tutorial is for collaborators making small changes to qgsim with RStudio
and GitHub Desktop. You do not need to know Git commands for the usual workflow.

## Safe workflow

**Pull -> edit -> test -> review changes -> commit -> push**

Following these steps in order reduces the chance of losing work or creating
conflicts with changes made by another collaborator.

## 1. Clone qgsim with GitHub Desktop

You only need to clone the repository once.

1. Open GitHub Desktop and sign in to GitHub if needed.
2. Select **File > Clone repository**.
3. Find and select the qgsim repository.
4. Choose a local folder where you want to keep the project.
5. Select **Clone**.

After cloning, GitHub Desktop shows the repository and its current files.

## 2. Open qgsim in RStudio

1. In GitHub Desktop, select **Repository > Show in Explorer**.
2. Double-click `qgsim.Rproj`.
3. Confirm that RStudio opens with `qgsim` shown as the active project.

Always open `qgsim.Rproj` before working. This helps RStudio use the correct
project folder.

## 3. Pull before starting work

Before editing anything:

1. Open the qgsim repository in GitHub Desktop.
2. Select **Fetch origin**.
3. If GitHub Desktop shows **Pull origin**, select it.

Pulling downloads changes that other collaborators have already pushed. Pull
again if you have left the project open for a long time before starting work.

## 4. Make a small change

Open the file in RStudio, make one focused change, and save it. For example,
correct a typo or clarify a short paragraph.

Keep unrelated changes separate. A small commit is easier to review and easier
to fix if something goes wrong.

Do not edit generated files such as `NAMESPACE` or files under `man/` by hand.
Ask for help if your change appears to require those files.

## 5. Run basic checks in RStudio

For a small documentation-only change, read the changed section in RStudio and
check that links, spelling, and formatting look correct.

For package changes, run these commands in the **RStudio Console**:

```r
devtools::load_all()
testthat::test_dir("tests/testthat")
```

The checks should finish without failures. Copy the error message and ask for
help if a check fails and the cause is unclear.

When a terminal command is specifically needed, run it in RStudio's
**Terminal** tab, not in the R Console. Most collaborators will not need
terminal commands for the workflow in this tutorial.

## 6. Review changed files in GitHub Desktop

Return to GitHub Desktop after saving and testing.

1. Open the **Changes** tab.
2. Review every listed file.
3. Select each file to inspect the highlighted additions and removals.
4. Make sure only intended files are selected for the commit.

Stop and ask for help if a file appears that you did not intentionally change.

Do not commit these local or generated files:

- `.Rproj.user/`
- `.Rhistory`
- `.RData`
- `.Ruserdata`
- `.quarto/`
- `AGENTS.md`
- Compiled artifacts such as `.dll`, `.so`, `.o`, and `.exe`

## 7. Write a good commit message

Use a short summary that says what changed. Start with an action word and be
specific.

Good examples:

- `Fix typo in backend documentation`
- `Clarify installation instructions`
- `Add test for plan validation`

Avoid vague messages such as `changes`, `update`, or `fix`.

## 8. Commit small changes to main

For an agreed, small change:

1. Confirm that GitHub Desktop shows the **main** branch.
2. Review the selected files one final time.
3. Enter the commit message in the **Summary** box.
4. Select **Commit to main**.

Committing records the change on your computer. It does not send the change to
GitHub yet.

Ask before committing if the change is large, changes package behavior, adds a
dependency, affects several unrelated files, or was not previously agreed.

## 9. Push changes to GitHub

After committing:

1. Select **Push origin** in GitHub Desktop.
2. Wait for the push to finish.
3. Check the repository on GitHub if you want to confirm that the commit is
   visible.

If GitHub Desktop says the remote repository has newer changes, pull first,
review the result, and then push again.

## If GitHub Desktop reports conflicts

Do not guess, delete files, or choose **Discard changes**.

1. Stop editing.
2. Leave GitHub Desktop and RStudio open.
3. Take a screenshot or copy the conflict message.
4. Ask a maintainer or experienced collaborator for help.

A conflict means that your work and another collaborator's work changed the
same part of a file. Both changes may be important.

## Ask for help before committing when

- GitHub Desktop lists files you did not intentionally change.
- A test fails and you do not understand why.
- GitHub Desktop reports a conflict.
- You are unsure whether a generated or compiled file should be included.
- The change modifies package behavior, dependencies, `NAMESPACE`, or `man/`.
- The change is larger than the small task you intended to complete.
- You are unsure whether committing directly to `main` is appropriate.

When asking for help, describe what you changed, what checks you ran, and what
GitHub Desktop or RStudio shows.
