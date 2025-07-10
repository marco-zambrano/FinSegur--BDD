-- Canales de comunicación
insert into sym_channel (channel_id, processing_order, max_batch_size, enabled, description)
values ('clientes', 1, 1000, 1, 'Replicación de clientes');
insert into sym_channel (channel_id, processing_order, max_batch_size, enabled, description)
values ('cuentas', 2, 1000, 1, 'Replicación de cuentas');
insert into sym_channel (channel_id, processing_order, max_batch_size, enabled, description)
values ('movimientos', 3, 1000, 1, 'Replicación de movimientos');
insert into sym_channel (channel_id, processing_order, max_batch_size, enabled, description)
values ('auditorias', 4, 1000, 1, 'Replicación de auditorias');
insert into sym_channel (channel_id, processing_order, max_batch_size, enabled, description)
values ('sucursales', 5, 1000, 1, 'Replicación de sucursales');


-- Grupos de Nodos
insert into sym_node_group (node_group_id, description)
values ('master', 'Grupo para el nodo master');
insert into sym_node_group (node_group_id, description)
values ('trans', 'Grupo para el nodo transaccional');
insert into sym_node_group (node_group_id, description)
values ('readonly', 'Grupo para el nodo de solo lectura');

-- Enlaces entre grupos (quién habla con quién)
-- Master <-> Trans
insert into sym_node_group_link (source_node_group_id, target_node_group_id, data_event_action)
values ('master', 'trans', 'P'); -- Push
insert into sym_node_group_link (source_node_group_id, target_node_group_id, data_event_action)
values ('trans', 'master', 'P'); -- Push
-- Master -> Readonly
insert into sym_node_group_link (source_node_group_id, target_node_group_id, data_event_action)
values ('master', 'readonly', 'P'); -- Push


-- Triggers (qué tablas monitorear)
insert into sym_trigger (trigger_id, source_table_name, channel_id, sync_on_update, sync_on_insert, sync_on_delete, last_update_time, create_time)
values ('clientes_trigger', 'clientes', 'clientes', 1, 1, 1, current_timestamp, current_timestamp);
insert into sym_trigger (trigger_id, source_table_name, channel_id, sync_on_update, sync_on_insert, sync_on_delete, last_update_time, create_time)
values ('cuentas_trigger', 'cuentas', 'cuentas', 1, 1, 1, current_timestamp, current_timestamp);
insert into sym_trigger (trigger_id, source_table_name, channel_id, sync_on_update, sync_on_insert, sync_on_delete, last_update_time, create_time)
values ('movimientos_trigger', 'movimientos', 'movimientos', 1, 1, 1, current_timestamp, current_timestamp);
insert into sym_trigger (trigger_id, source_table_name, channel_id, sync_on_update, sync_on_insert, sync_on_delete, last_update_time, create_time)
values ('auditorias_trigger', 'auditorias', 'auditorias', 1, 1, 1, current_timestamp, current_timestamp);
insert into sym_trigger (trigger_id, source_table_name, channel_id, sync_on_update, sync_on_insert, sync_on_delete, last_update_time, create_time)
values ('sucursales_trigger', 'sucursales', 'sucursales', 1, 1, 1, current_timestamp, current_timestamp);


-- Routers (cómo dirigir los datos)
-- Regla general: Master envía todo a Trans y Readonly
insert into sym_router (router_id, source_node_group_id, target_node_group_id, create_time, last_update_time)
values ('master_to_all', 'master', 'trans', current_timestamp, current_timestamp);
insert into sym_router (router_id, source_node_group_id, target_node_group_id, create_time, last_update_time)
values ('master_to_readonly', 'master', 'readonly', current_timestamp, current_timestamp);

-- Regla: Trans envía cuentas, movimientos y auditorias a Master
insert into sym_router (router_id, source_node_group_id, target_node_group_id, create_time, last_update_time)
values ('trans_to_master', 'trans', 'master', current_timestamp, current_timestamp);


-- Enlazar Triggers con Routers
-- Clientes: Master -> Trans, Master -> Readonly
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('clientes_trigger', 'master_to_all', 100, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('clientes_trigger', 'master_to_readonly', 100, current_timestamp, current_timestamp);

-- Cuentas: Master <-> Trans, Master -> Readonly
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('cuentas_trigger', 'master_to_all', 100, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('cuentas_trigger', 'master_to_readonly', 100, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('cuentas_trigger', 'trans_to_master', 100, current_timestamp, current_timestamp);

-- Movimientos: Master <-> Trans
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('movimientos_trigger', 'master_to_all', 100, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('movimientos_trigger', 'trans_to_master', 100, current_timestamp, current_timestamp);

-- Auditorias: Trans -> Master -> Readonly
-- Trans -> Master
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('auditorias_trigger', 'trans_to_master', 100, current_timestamp, current_timestamp);
-- Master -> Readonly (para que lo que llega de Trans se reenvíe a Readonly)
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('auditorias_trigger', 'master_to_readonly', 100, current_timestamp, current_timestamp);

-- Sucursales: Replicar a todos desde master (como default)
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('sucursales_trigger', 'master_to_all', 100, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('sucursales_trigger', 'master_to_readonly', 100, current_timestamp, current_timestamp);