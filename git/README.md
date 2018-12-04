# Git Commands To Remember
Here are all the important git commands that I always tend to forever or even bother to commit to memory.

## Creating Repositories
Start a new repository or obtain one from an existing URL.
```bash
git init [project-name]
```
> Creates a new local repository with the specified name

```bash
git clone [url]
```
> Downloads a project and its entire version history

## Making Changes
Review edits and craft a commit transaction
```bash
git status
```
> List all new or modified files to be committed

```bash
git diff
```
> Shows file difference not yet staged

```bash
git add [file]
```
> Snapshots the file in preparation for versioning

```bash
git diff --staged
```
> Shows file differences between staging and the last file version

```bash
git reset [file]
```
> Unstages the file, but preserves its content

```bash
git commit -m "[descriptive message]"
```
> Records file snapshots permanently in version history

## Group Changes
Name a series of commits and combine completed efforts

```bash
git branch
```
> Get a list of all local branches

```bash
git branch -d [branch name]
```
> Deletes a local branch

```bash
git checkout -b [branch name]
```
> After forking a project you can run the following commands to make a local branch on your computer

```bash
git checkout [branch name]
```
> Switches to the specified branch and updates the working directory

## Synchronize Changes

```bash
git push [alias] [branch]
```
> Uploads all local branch commits to git server
