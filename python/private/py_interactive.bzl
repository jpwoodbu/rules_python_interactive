"""Macro to create an interactive Python shell for a py_library."""

load("@rules_python//python:defs.bzl", "py_binary")

def _quote_args(args):
    """Wrap Python statements in quotes.

    This prevents statements with whitespace from being broken up within sys.argv.
    """
    return ['"{}"'.format(a) for a in args]

def _py_interactive_impl(name, deps, pushes, **kwargs):
    """Create a py_binary target to run an interactive Python shell."""
    py_binary(
        name = name,
        # TODO(jpwoodbu) Find some way to reference interactive.py without using
        # a repo name that might be different from the repo name chosen by
        # another user in their MODULE.bazel file. I've tried removing the repo
        # name (e.g. //python:interactive.py), but that fails as Bazel looks for
        # it in the module from where the macro is run. I've tried a relative
        # path, as suggested by AI, like ..:interactive.py, which did not appear
        # to be valid.
        srcs = ["@rules_python_interactive//python:interactive.py"],
        main = "@rules_python_interactive//python:interactive.py",
        deps = deps,
        args = _quote_args(pushes),
        **kwargs
    )

py_interactive = macro(
    attrs = {
        "deps": attr.label_list(
            mandatory = True,
            doc = "The target(s) which are made available (i.e. importable) within the Python shell",
        ),
        "pushes": attr.string_list(
            mandatory = False,
            # configurable = False prevents the pushes arg from being wrapped in
            # a select type, which I've not figured out how to handle and isn't
            # obviously useful in this case.
            configurable = False,
            doc = "Python statements run in the Python shell at start time",
        ),
    },
    implementation = _py_interactive_impl,
)
