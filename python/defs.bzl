"""Public API for `rules_python_interactive`.

This file re-exports the `py_interactive` macro, which can be used to create an
interactive Python shell target.
"""

load("//python/private:py_interactive.bzl", _py_interactive = "py_interactive")

py_interactive = _py_interactive
