server_config = {
    'server1': {'ip': '192.168.1.1', 'port': 8080, 'status': 'active'},
    'server2': {'ip': '192.168.1.2', 'port': 8000, 'status': 'inactive'},
    'server3': {'ip': '192.168.1.3', 'port': 9000, 'status': 'active'}
}

def get_server_config(server_name):
    return server_config.get(server_name, {}).get('status', 'Server not found')
print("server_name: ", get_server_config('server1'))  # Output: active
