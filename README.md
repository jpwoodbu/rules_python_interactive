# rules_python_interactive

This module makes it easy to start a Python shell **(with tab completition!)**
which can import modules from `py_library` targets for easier debugging. What it
does is similar to what the
[REPL](https://github.com/bazel-contrib/rules_python/blob/main/docs/repl.md)
feature in `rules_python` does, but for some, perhaps more ergonomically.
Importantly, if you commonly need a Python shell for debugging,
`rules_python_interactive` makes starting one as easy as running a Bazel target.

## Setup

Modify your `MODULE.bazel` file to load `rules_python_interactive`. For example:

```bzl
bazel_dep(name = "rules_python_interactive", version = "0.2.0")

git_override(
    module_name = "rules_python_interactive",
    remote = "https://github.com/jpwoodbu/rules_python_interactive.git",
    branch = "main",
)
```

Modify a `BUILD.bazel` file to use `py_interactive`:

```bzl
load("@rules_python_interactive//python:defs.bzl", "py_interactive")

# one or more py_library rules of your own here...

py_interactive(
    name = "my_library_interactive",  # This can be any name you like.
    deps = "[:my_library]",
)
```
Note that `py_interactive` wraps
[py_binary](https://bazel.build/reference/be/python#py_binary), so any argument
`py_binary` takes can also be passed to `py_interactive` with the exception of
`srcs`, `main`, and `args`.

## Usage

Run the `py_interactive` target:

```sh
$ bazel run :my_library_interactive
INFO: Analyzed target //:my_library_interactive (80 packages loaded, 3454 targets configured).
INFO: Found 1 target...
Target //:my_library_interactive up-to-date:
  bazel-bin/my_library_interactive
INFO: Elapsed time: 0.534s, Critical Path: 0.00s
INFO: 1 process: 5 action cache hit, 1 internal.
INFO: Build completed successfully, 1 total action
Bazel py_interactive ready.
>>> import my_library
>>> my_library.foo()
We are fooing!!!
```

## Pushes argument

If there is some setup you'd like run in the Python shell at start up, e.g.
importing your library, you can add arbitrary Python statements to run on the
shell using the `pushes` argument for the `py_interactive` macro. They will be
run in order and with **no error handling**. If a statement produces an error,
it is ignored and any further statements will still be attempted.

For example:

```bzl
py_interactive(
    name = "my_library_interactive",
    deps = "[:my_library]",
    pushes = [
        "import my_library",
        "my_library.do_some_set_up()",
    ]
)
```

## Custom repo name

When modifying your `MODULE.bazel` file, if you passed a `repo_name` argument to
`bazel_dep`, then you must also pass the same `repo_name` value to each
`py_interactive` target. This is due to the macro needing to make a reference to
a Python script inside the `rules_python_interactive` module used to start the
Python shell.

For example:

`MODULE.bazel`
```bzl
bazel_dep(name = "rules_python_interactive", version = "0.2.0", repo_name="some_other_repo_name")
```

`BUILD.bazel`
```bzl
py_interactive(
    name = "my_library_interactive",
    deps = "[:my_library]",
    repo_name = "some_other_repo_name",
)
```
