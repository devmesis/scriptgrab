import secrets, string

# ────────────────────────────────────────────────
#  🐍 ScriptGrab: Run any shell script straight from GitHub — no fluff, just speed.
# By Devmesis
# ────────────────────────────────────────────────

# Color setup
try:
    from colorama import init, Fore, Style
    init(autoreset=True)
except ImportError:
    class Dummy:
        RESET_ALL = ''
        BRIGHT    = ''
        def __getattr__(self, name):
            return ''
    Fore = Style = Dummy()

def generate_password(length=12):
    chars = string.ascii_letters + string.digits + string.punctuation
    return ''.join(secrets.choice(chars) for _ in range(length))

def boxed(message, color=Fore.CYAN, style=Style.BRIGHT):
    border = f"+{'-' * len(message)}+"
    return "\n".join([
        f"{color}{border}",
        f"{color}|{style}{message}{color}|",
        f"{color}{border}{Style.RESET_ALL}",
    ])

if __name__ == "__main__":
    pwd = generate_password()
    header = " Your safe password: "

    # Print header in a colored box
    print(boxed(header))

    # Blank line + password + blank line for easy copy/paste
    print()
    print(f"{Style.BRIGHT}{Fore.GREEN}{pwd}{Style.RESET_ALL}")
    print()
