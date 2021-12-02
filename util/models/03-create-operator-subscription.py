from helper import get_environ, loader, dumper
from helper import namespace

operator = get_environ('operator')
channel = get_environ('channel')
startingcsv = get_environ('starting_csv')

_content = loader('operator-subscription')
_content['metadata']['namespace'] = namespace
_content['metadata']['name'] = f"{operator}-mvp"
_content['spec']['name'] = operator
_content['spec']['channel'] = channel
_content['spec']['startingCSV'] = startingcsv

_ = dumper('operator-subscription', _content)