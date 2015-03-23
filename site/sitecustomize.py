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
    import sys
    import imp
    sys.modules['pygments'] = imp.load_module(
        'pygments',
        *imp.find_module('pygments', ['/Library/Python/2.7/site-packages/'])
    )

    import cmd
    import contextlib
    import os
    import pdb
    import pprint
    import re
    import rlcompleter
    import subprocess
    import sys
    from cStringIO import StringIO

    from pygments import highlight
    from pygments.lexers import PythonLexer, PythonTracebackLexer
    from pygments.formatters import Terminal256Formatter

    @contextlib.contextmanager
    def style(im_self, filepart=None, lexer=PythonLexer):
        old_stdout = im_self.stdout
        buff = StringIO()
        im_self.stdout = buff
        yield

        value = buff.getvalue()
        context = len(value.splitlines())
        file_cache = {}

        if filepart:
            filepath, lineno = filepart
            if filepath not in file_cache:
                with open(filepath, 'r') as source:
                    file_cache[filepath] = source.readlines()
            value = ''.join(file_cache[filepath][:lineno-1]) + value

        formatter = Terminal256Formatter(style='friendly')
        value = highlight(value, lexer(), formatter)

        # Properly format line numbers when they show up in multi-line strings
        strcolor, _ = formatter.style_string['Token.Literal.String']
        intcolor, _ = formatter.style_string['Token.Literal.Number.Integer']
        value = re.sub(
            r'%s([0-9]+)' % re.escape(strcolor),
            lambda match: intcolor + match.group(1) + strcolor,
            value,
        )

        # Highlight the "current" line in yellow for visibility
        lineno = im_self.curframe.f_lineno

        value = re.sub(
            '(?<!\()%s%s[^\>]+>[^\[]+\[39m([^\x1b]+)[^m]+m([^\n]+)' % (re.escape(intcolor), lineno),
            lambda match: ''.join([
                str(lineno),
                ' ->',
                '\x1b[93m',
                match.group(1),
                re.sub('\x1b[^m]+m', '', match.group(2)),
                '\x1b[0m'
            ]),
            value
        )

        if filepart:
            _, first = filepart
            value = '\n'.join(value.splitlines()[-context:]) + '\n'

        if value.strip():
            old_stdout.write(value)
        im_self.stdout = old_stdout

    class CustomPdb(pdb.Pdb):

        def cmdloop(self):
            self.do_list(tuple())
            return cmd.Cmd.cmdloop(self)

        def do_list(self, args):
            lines = int(subprocess.check_output(['tput', 'lines']))
            context = (lines - 2) / 2
            if not args:
                first = max(1, self.curframe.f_lineno - context)
                last = first + context * 2 - 1
                args = "(%s, %s)" % (first, last)
            self.lineno = None
            with style(self, (
                self.curframe.f_code.co_filename, self.curframe.f_lineno - context)
            ):
                return pdb.Pdb.do_list(self, args)
        do_l = do_list

        def format_stack_entry(self, *args, **kwargs):
            entry = pdb.Pdb.format_stack_entry(self, *args, **kwargs)
            return '\n'.join(
                filter(lambda x: not x.startswith('->'), entry.splitlines())
            )

        def print_stack_entry(self, *args, **kwargs):
            with style(self):
                return pdb.Pdb.print_stack_entry(self, *args, **kwargs)

        def set_next(self, curframe):
            os.system('clear')
            pdb.Pdb.set_next(self, curframe)

        def set_return(self, arg):
            os.system('clear')
            pdb.Pdb.set_return(self, arg)

        def set_step(self):
            os.system('clear')
            pdb.Pdb.set_step(self)

        def print_stack_trace(self):
            with style(self, lexer=PythonTracebackLexer):
                return pdb.Pdb.print_stack_trace(self)

        def default(self, line):
            with style(self):
                return pdb.Pdb.default(self, line)

        def parseline(self, line):
            line = line.strip()
            if line == '?':
                line = 'dir()'
            if line.endswith('?'):
                line = 'dir(%s)' % line[:-1]
            return cmd.Cmd.parseline(self, line)

        def displayhook(self, obj):
            if obj is not None and not isinstance(obj, list):
                return pprint.pprint(obj)
            return pdb.Pdb.displayhook(self, obj)


    def set_trace():
        return CustomPdb().set_trace(sys._getframe().f_back)

    pdb.__dict__['set_trace'] = set_trace
except ImportError:
    pass
