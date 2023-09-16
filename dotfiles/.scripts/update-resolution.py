import subprocess

def get_connected_monitors():
    output = subprocess.check_output('xrandr').decode('utf-8')
    monitors = []
    for line in output.split('\n'):
        if ' connected' in line:
            monitor = line.split()[0]
            monitors.append(monitor)
    return monitors

def set_resolution(monitor):
    print(f"=== Monitor {monitor} identificado, atualizando resolução.")
    subprocess.call(['xrandr', '--output', monitor, '--auto'])

monitors_before = get_connected_monitors()

while True:
    monitors_after = get_connected_monitors()
    if len(monitors_after) > len(monitors_before):
        new_monitors = list(set(monitors_after) - set(monitors_before))
        for monitor in new_monitors:
            set_resolution(monitor)
    monitors_before = monitors_after

