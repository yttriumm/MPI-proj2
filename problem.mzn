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
array[Servers] of var int: servers_cpu_load;
array[Servers] of var int: servers_ram_load;
array[Servers] of var int: servers_total_load;
var int: mean_server_load;
array[Servers] of var int: servers_imbalance;
var int: mean_servers_imbalance;

constraint forall(server in Servers)
                    (servers_cpu_load[server] = 1000 * (sum(service in Services)(assignment[server, service] * vms_cpu[service])) div servers_cpu[server])
;

constraint forall(server in Servers)
                    (servers_ram_load[server] = 1000 * (sum(service in Services)(assignment[server, service] * vms_ram[service])) div servers_ram[server])
;

constraint forall(server in Servers)
                   (servers_total_load[server] = servers_cpu_load[server] + servers_ram_load[server]);

constraint mean_server_load = sum(server in Servers)(servers_total_load[server]) div length(Servers);


constraint forall(server in Servers)(servers_imbalance[server] = ( abs(servers_total_load[server] - mean_server_load)) );

constraint forall(server in Servers)
                   (sum(service in Services)(vms_cpu[service]*assignment[server,service]) <= servers_cpu[server])
;



constraint mean_servers_imbalance = sum(servers_imbalance) div length(Servers);

constraint forall(server in Servers)
                   (sum(service in Services)(vms_ram[service]*assignment[server,service]) <= servers_ram[server])
;

constraint forall(service in Services)
                    (sum(server in Servers)(assignment[server, service] * vms_load_capability[service]) >= demands[service]);


solve minimize mean_server_load + mean_servers_imbalance;



