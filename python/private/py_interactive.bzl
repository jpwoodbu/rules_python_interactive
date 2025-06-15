"""Macro to create an interactive Python shell for a py_library."""

# TODO(jpwoodbu) Load py_binary from rules python instead of using native, which
# is deprecated.


def _quote_args(args):
  """Wrap Python statements in quotes.

  This prevents statements with whitespace from being broken up within sys.argv.
  """
  return ['"{}"'.format(a) for a in args]


# TODO(jpwoodbu) Making this a "symbolic macro" might resolve the issue on the
# srcs attr before having to match the name of the repo_name in the user's
# bazel_dep entry.
def py_interactive(name, deps, pushes, **kwargs):
  """Create a py_binary target to run an interactive Python shell.

  deps: list of labels, the target(s) which are made available (i.e.
    importable) within the Python shell.
  pushes: list of str, Python statements run on the interpreter at start time.
  """
  native.py_binary(
    name = name,
    srcs = ["@rules_python_interactive//python:interactive.py"],
    main = "interactive.py",
    deps = deps,
    args = _quote_args(pushes),
    **kwargs,
  )
