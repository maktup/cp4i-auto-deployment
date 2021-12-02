from helper import get_environ, loader, dumper
from helper import sc_rwx, namespace

version = get_environ('version_platform_navigator')
license = get_environ('license_id_platform_navigator')

_content = loader('platform-navigator')

_content['metadata']['namespace'] = namespace
_content['spec']['version'] = version
_content['spec']['storage']['class'] = sc_rwx
_content['spec']['license']['license'] = license

_ = dumper('platform-navigator', _content)