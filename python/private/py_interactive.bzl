"""Macro to create an interactive Python shell for a py_library."""

load("@rules_python//python:defs.bzl", "py_binary")

def _quote_args(args):
    """Wrap Python statements in quotes.

    This prevents statements with whitespace from being broken up within sys.argv.
    """
    return ['"{}"'.format(a) for a in args]

def _py_interactive_impl(name, deps, pushes, repo_name, **kwargs):
    """Create a py_binary target to run an interactive Python shell."""
    py_binary(
        name = name,
        srcs = ["@%s//python:interactive.py" % repo_name],
        main = "@%s//python:interactive.py" % repo_name,
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
            # configurable = False prevents this arg from being wrapped in a
            # select type, which I've not figured out how to handle and isn't
            # obviously useful in this case.
            configurable = False,
            doc = "Python statements run in the Python shell at start time",
        ),
        "repo_name": attr.string(
            mandatory = False,
            default = "rules_python_interactive",
            # configurable = False prevents the this arg from being wrapped in a
            # select type, which I've not figured out how to handle and isn't
            # obviously useful in this case.
            configurable = False,
            doc = "If you set a custom repo name when loading the rules_python_interactive module in your MODULE.bazel or WORKSPACE file, you must pass it here",
        ),
    },
    implementation = _py_interactive_impl,
)
