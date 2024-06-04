#!/usr/bin/env python3
# Masterfully formulated by Sir Dr. Rev. Peloton, Esq.

import json # Loads the output of 1Password's CLI
import sys # Used for output redirection (sys.stderr) and exits
import shutil # For several convenience functions, notably a UNIX `which`-like function and gzipping
import os
import re

# Set if this program seems to be selecting the wrong executable for op
OP_EXE = None

def is_wsl() -> bool:
    """Returns whether or not this script is being executed in a WSL environment.
    """
    import platform
    return re.search("microsoft", platform.uname().release, re.IGNORECASE) != None

def get_op_exe() -> str | None:
    """Find the appropriate executable for the 1Password CLI

    Returns:
        str: Path to the 1Password CLI executable
    """
    if OP_EXE:
        return OP_EXE
        
    if is_wsl():
        return shutil.which("op.exe")
    else:
        return shutil.which("op")

def call_shell(cmd: str) -> str:
    """Calls shell within child process and returns stdout
    Args:
        cmd (str): Command to run
    Returns:
        str: Stdout of `cmd`
    """
    import shlex # For splitting
    import subprocess # Duh
    res = b''
    with subprocess.Popen(shlex.split(cmd), stdout=subprocess.PIPE) as p:
        for line in p.stdout:
            res += line

    return str(res, 'ascii')

class SSHConfigEntry:
    """Wrapper for SSH config entries. Stores basic config parameters.
    """
    def __init__(self, json: list[dict]):
        """Creates an entry from the output of `json.loads()`, which in turn should be loading the JSON-formatted return of an SSH key from the 1Password CLI.

        Args:
            json (list[dict]): The return from `json.loads()` when parsing `op get item --format json`'s output. This function is hardcoded to expect two fields,
                in order, as the public key and the "chezmoi params" field. The only required "chezmoi param" is `url`.

        Raises:
            ValueError: Raised if `url` is not specified in `chezmoi params`.
        """
        # 1Password CLI always returns fields in the order specified by the command, so this can be hardcoded
        self.key = json[0]['value']

        # Extract the key's title in 1Password from the secret reference
        # This is a really janky workaround to avoid polling 1Password separately for the fields and the title
        # Retrieving the entire password entry isn't so much of an option either as the JSON output's format is (somehow) not all that machine friendly for parsing
        # So anyways, here we are
        ref = json[0]['reference']
        try:
            self.keyname = re.match(r'^op:\/\/(?:\w+\s*)*?\/((?:\w+\s*)*)/.*$', ref).group(1)
        except IndexError:
            self.keyname = None

        # Initial blank values for all options
        self.options: None | str = None
        self.user: None | str = None
        self.aliases: None | str = None
        self.url: None | str = None

        # Loop through the provided parameters and set any that we find
        parameters: list[str] = json[1]['value'].split('\n')
        for param in parameters:
            key, value = param.split(' ', 1)
            setattr(self, key, value)

        # URL is the only required parameter, as we don't even know what this key connects to otherwise
        if self.url == None:
            raise ValueError(f'Key does not specify a URL to connect to! Add a URL field to the 1Password entry for {self.keyname}')
        
        # Fall back if we can't parse the key name from the secret reference
        if self.keyname == None:
            self.keyname = self.url

        # Make the resulting key name a little more friendly when serialization time comes
        self.keyname = self.keyname.replace(' ', '_')

    def _make_key(self, path: str):
        """Generate the key file

        Args:
            path (str): Path to output the key file
        """
        with open(os.path.join(path, self.keyname + '.pub'), 'w') as fout:
            fout.write(self.key)
            
    def serialize(self, path: str) -> str:
        """Represent this class instance as a valid SSH config entry

        Args:
            path (str): Path to the `.ssh` directory on the local machine

        Returns:
            str: Serialized form of the class instance
        """
        print(f'Generating key and config entry for {self.keyname}')

        # Generate the key file
        self._make_key(path)

        # Output the required pieces of the config entry
        res = f'Host {self.url} {self.aliases.replace(",", " ") if self.aliases else ""}\n'
        res += f'\tHostName {self.url}\n'
        res += f'\tIdentityFile "{os.path.join('%d', '.ssh', self.keyname + '.pub')}"\n'
        res += f'\tIdentitiesOnly yes\n'
        
        if self.user:
            res += f'\tUser {self.user}\n'

        # Set all of the extra options exactly as specified in the 1Password entry
        if self.options:
            opts = self.options.split(',')
            for opt in opts:
                res += f'\t{opt}\n'

        return res
    
def get_ssh_path() -> str:
    """Get the path to the `.ssh` directory on the local machine. Only supports UNIX-like environments
    """
    if is_wsl():
        # Use PowerShell to derive the Windows username if possible
        if ps := shutil.which('powershell.exe'):
            win_user = call_shell(f'{ps} \'$env:UserName\'').strip()
        else:
            print('Hi! You appear to be using WSL, so we need some extra info.')
            win_user = input('What is your Windows username? ')
            print('Thanks, back to work!')

        return f'/mnt/c/users/{win_user}/.ssh'
    else:
        return f'/home/{os.getlogin()}/.ssh'
    
def make_config(entries: list[SSHConfigEntry], path: str) -> None:
    """Generate the SSH config file itself

    Args:
        entries (list[SSHConfigEntry]): List of entries to add to the config file
        path (str): Path to the `.ssh` directory locally
    """
    # Create a backup of the old directory if it already exists
    if os.path.exists(path):
        import time
        new_loc = shutil.make_archive(base_name=f'{path}-{time.strftime("%Y%m%d-%H%M%S")}.old', format='gztar', root_dir=path)
        print(f'Moving old version of .ssh directory to a backup location at "{new_loc}"')
        shutil.rmtree(path)
    
    os.mkdir(path)
    
    with open(os.path.join(path, 'config'), 'w') as fout:
        fout.write('# This file was automatically generated by a Chezmoi script. Changes will be overwritten if `chezmoi apply` or `chezmoi update` is ran.\n')
        fout.write(f'# You can find the script somewhere in the directory opened with `chezmoi cd`.\n\n')

        if not is_wsl():
            # Specify the 1Password agent if we aren't in WSL. Windows uses a global pipe instead
            fout.write('Host *\n\tIdentityAgent ~/.1password/agent.sock\n')
        for entry in entries:
            fout.write('\n')
            fout.write(entry.serialize(path))

def main():
    # Identify the 1Password CLI and quit if it's not installed
    OP_EXE = get_op_exe()
    if OP_EXE is None:
        print("1Password CLI not installed! Quitting.", file=sys.stderr)
        if is_wsl():
            print("Hint: If you're trying to use WSL, you need the Windows CLI installed, not Linux!", file=sys.stderr)
        sys.exit(1)

    print('Generating a new SSH directory...')

    # Create a backup of the old directory if applicable!
    path = get_ssh_path()
    if os.path.exists(path):
        while True:
            match input('This will replace your existing directory, but a backup will be made. Continue? (Y/n) ').lower().strip():
                case 'y' | '':
                    break
                case 'n':
                    sys.exit(0)
    
    # Get all SSH Key entries by ID
    get_entries_res = call_shell(f'{OP_EXE} item list --categories SSHKEY --format json')
    key_ids = []
    for key in json.loads(get_entries_res):
        # Omit the signing key - this is hardcoded! :(
        if re.search('signing', key['title'], re.IGNORECASE):
            print(f'Omitting {key['title']} - this key appears to be for signing!')
            continue

        key_ids.append(key['id'])

    # Get desired fields from each entry by entry ID
    entries: list[SSHConfigEntry] = []
    for key in key_ids:
        res = call_shell(f'{OP_EXE} item get --format json --fields label="public key",label="chezmoi params" {key}')
        entry = SSHConfigEntry(json.loads(res))
        entries.append(entry)

    make_config(entries, path)

if __name__ == '__main__':
    main()