import sys, os, time, base64, json

try:
    from dotenv import load_dotenv
except ImportError as e:
    print("dotenv is missing. Please check step 2", file=sys.stderr)

try:
    import yaml
except ImportError as e:
    print("yaml is missing. Please check step 2", file=sys.stderr)
   
load_dotenv()

def execute(command):
    return os.popen(command)

def get_environ(key):
    return os.environ.get(key)
    
def loader(filename):
    with open(f"definitions/{filename}.yml", 'r') as s:
        try:
            return (yaml.safe_load(s))
        except yaml.YAMLError as e:
            return e

def dumper(filename, data):
    with open(f"definitions/{filename}.yml", 'w') as s:
        try:
            yaml.dump(data, s)
        except yaml.YAMLError as e:
            return e

def get_file_path(filename):
    return f"definitions/{filename}.yml"

def encode(plaintext):
    return base64.b64encode(json.dumps(plaintext).encode())

def animate(_range):
    for x in range(_range):
        print('-', end='', flush=True)
        time.sleep(0.1)

namespace = get_environ('namespace')
sc_rwx = get_environ('storage_class_rwx')
sc_rwo = get_environ('storage_class_rwo')