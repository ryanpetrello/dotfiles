import imp
import sys

try:
    import readline
except ImportError:
    print("Module readline not available.")
else:
    import rlcompleter
    if 'libedit' in readline.__doc__:
        readline.parse_and_bind("bind ^I rl_complete")
    else:
        readline.parse_and_bind("tab: complete")

try:
    sys.modules['IPython'] = imp.load_module(
        'IPython',
        *imp.find_module('IPython', ['/Library/Python/2.7/site-packages/'])
    )
    sys.modules['ipdb'] = imp.load_module(
        'ipdb',
        *imp.find_module('ipdb', ['/Library/Python/2.7/site-packages/'])
    )
    import pdb
    import ipdb
    pdb.__dict__['set_trace'] = ipdb.set_trace
except ImportError:
    pass
