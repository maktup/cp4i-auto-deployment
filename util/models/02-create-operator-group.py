from helper import loader, dumper
from helper import namespace

_content = loader('operator-group')
_content['metadata']['namespace'] = namespace
_content['spec']['targetNamespaces'] = [namespace]

_ = dumper('operator-group', _content)