# vcr

Record and replay shell commands.

# What is this and why would I need it?

I often found myself in a situation where I set up my work environments by
executing some (identical) sequences of commands. While you might suggest
that just keeping a tmux session open might be the way to go, that was not a
good option for technical reasons.
The `script` command might have been an option but I find it somewhat awkward to
use.
So instead I wrote this ~130 line bash script to record, store and replay repetative
shell commands to save me from the dreads of repetition.

# Usage

Without further ado, let's get to an example. Here's how you store a record (command
sequence):

```bash
user@host ~
$ vcr-record
[recording...]

user@host ~
$ module load cmake llvm cuda

user@host ~
$ cd /my/project/dir

user@host /my/project/dir
$ . some-environemtn

user@host /my/project/dir
$ vim -p file1.cc file2.cc
-- open vim, then quit

user@host /my/project/dir
$ vcr-label myproject-src
[stored record under label 'myproject-src']
```

After setting up your environment with `vcr-record` and storing it with `vcr-label`
you can replay it like this:

```bash
user@host
$ vcr-play myproject-src
[playing record...]
[done]
# current dir is now /my/project/dir and vim is opened with file1.cc and file2.cc
```

# Installation

Copy the vcr.bash somewhere and source it in your `~/.bashrc` (or `~/.bash_profile` on macOS).
If there's any demand, support for more shells might follow.

# Okay, got it, so that's it?

Yes, that's essentially all there is to it. There's some convenience commands to manage
and preview your records and tab-completion for the appropriate commands but the whole
thing is kept lightweight.

# What are the commands?

- `vcr-record`, starts a recording if not already recording
- `vcr-abort`, abort and discard the current recording session
- `vcr-recording`, prints a message about whether you are recording
- `vcr-label <name>`, close current recording and save it under `<name>`
- `vcr-list`, list all records
- `vcr-delete <name>`, delete the record `<name>`
- `vcr-clear`, delete all records
- `vcr-show <name>`, print all commands in record `<name>`
- `vcr-play <name>`, execute all commands in record `<name>` in current shell

All commands with a `<name>` arguments provide tab-completion

# What are the alternatives?

You could:

1) Use the `script` command to open a new shell, save it to a file and then source it the next time.
I personally think it's kind of a hassle and you have to remember where you store your scripts.

2) Keep a `tmux` session open with a set up environment. That is not always possible on remote machines
and in addition I noticed you kind of get angsty about ever closing that tmux session.

3) Write your own shellscript with the required commands by hand and source it on every start. That's
the manual version of the `script` variant and comes with all the drawbacks and no additional benefits.

4) I don't know, if you can think of something nicer let me know :)

# License

MIT @ Alexander Matz
