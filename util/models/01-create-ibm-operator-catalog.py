from helper import loader, dumper
from helper import namespace

_content = loader('new-project')
_content['metadata']['name'] = namespace
_ = dumper('new-project', _content)