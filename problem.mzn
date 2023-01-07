enum Services;
enum Servers;

array[Services] of int: vms_cpu;
array[Services] of int: vms_ram;
array[Services] of int: vms_load_capability;

array[Services] of int: demands;

array[Servers] of int: servers_cpu;
array[Servers] of int: servers_ram;

int: maxInstances = max(server in Servers, service in Services)(min(servers_cpu[server] div vms_cpu[service], servers_ram[server] div vms_cpu[service]));

array[Servers, Services] of var 0..maxInstances: assignment;

array[Servers] of var float: servers_cpu_load;
array[Servers] of var float: servers_ram_load;
array[Servers] of var float: servers_total_load;

constraint forall(server in Servers)(servers_cpu_load[server] = sum(service in Services)((vms_cpu[service]*assignment[server, service])/servers_cpu[server]));
constraint forall(server in Servers)(servers_ram_load[server] = sum(service in Services)((vms_ram[service]*assignment[server, service])/servers_ram[server]));
constraint forall(server in Servers)(servers_total_load[server] = servers_cpu_load[server] + servers_ram_load[server]);

constraint forall(server in Servers)(servers_cpu_load[server] <= 1);
constraint forall(server in Servers)(servers_ram_load[server] <= 1);

constraint forall(service in Services)(sum(server in Servers)(assignment[server, service] * vms_load_capability[service]) >= demands[service]);

var float: average_load = sum(servers_total_load)/length(Servers);
solve minimize sum(server in Servers)(pow((servers_total_load[server] - average_load), 2));


