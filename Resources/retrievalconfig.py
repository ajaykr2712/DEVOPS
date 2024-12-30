# Dictionary containing server configurations
server_config = {
    'server1': {'ip': '192.168.1.1', 'port': 8080, 'status': 'active'},
    'server2': {'ip': '192.168.1.2', 'port': 8000, 'status': 'inactive'},
    'server3': {'ip': '192.168.1.3', 'port': 9000, 'status': 'active'}
}

def get_server_status(server_name):
    """
    Retrieve the status of a specified server from the server configuration.
    
    Parameters:
        server_name (str): The name of the server (e.g., 'server1').
        
    Returns:
        str: The status of the server ('active', 'inactive', or 'Server not found').
    """
    return server_config.get(server_name, {}).get('status', 'Server not found')

# Example usage
print("Server Status:", get_server_status('server1'))  # Output: active
