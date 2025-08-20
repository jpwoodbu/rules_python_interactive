import code

try:
    import readline
except ImportError:
    pass  # not all platforms have readline
import rlcompleter
import sys


class DynamicCompleter(rlcompleter.Completer):
    """
    A custom completer that dynamically updates its namespace
    to include new imports made within the interactive session.
    """

    def __init__(self, namespace):
        # We store a *reference* to the namespace, not a copy,
        # so that changes to the namespace are reflected.
        self.namespace = namespace

    def complete(self, text, state):
        # Temporarily update the completer's internal namespace
        # with the current interactive session's locals and globals.
        # This is the key to making new imports discoverable.
        rlcompleter.Completer.__init__(self, self.namespace)
        return super().complete(text, state)


def main(argv: list[str]) -> None:
    # This dictionary will serve as the namespace for the interactive session.
    # We initialize it with the current globals so that built-ins and
    # modules imported in the script itself are available from the start.
    interactive_namespace = globals().copy()

    if "readline" in globals():
        # Set up the dynamic completer, passing the interactive_namespace
        # This is the crucial change.
        completer = DynamicCompleter(interactive_namespace)
        readline.set_completer(completer.complete)

        # Enable tab completion
        # TODO(jpwoodbu) Use readline.backend instead of readline.__doc__ once we
        # can depend on having Python >=3.13.
        if "libedit" in (readline.__doc__ or ""):
            readline.parse_and_bind("bind ^I rl_complete")
        elif "GNU readline" in (readline.__doc__ or ""):
            readline.parse_and_bind("tab: complete")
        else:
            print("Could not enable tab completion!")
    else:
        print(
            "WARNING: Tab completion not enabled: "
            "readline module unavailable on this platform."
        )

    console = code.InteractiveConsole(locals=interactive_namespace)
    # Run statements provided as arguments on the command line, i.e. "pushes".
    if len(argv) > 1:
        for a in argv[1:]:
            console.push(a)

    # Start the interactive shell
    console.interact(banner="Bazel py_interactive ready.")


if __name__ == "__main__":
    main(sys.argv)
