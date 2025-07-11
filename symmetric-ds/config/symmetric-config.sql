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

-- Triggers (qué tablas monitorear)
-- NOTA: Para auditorias, el trigger solo debe existir en 'trans'
insert into sym_trigger (trigger_id, source_table_name, channel_id, sync_on_update, sync_on_insert, sync_on_delete, last_update_time, create_time)
values ('clientes_trigger', 'clientes', 'clientes', 1, 1, 1, current_timestamp, current_timestamp);
insert into sym_trigger (trigger_id, source_table_name, channel_id, sync_on_update, sync_on_insert, sync_on_delete, last_update_time, create_time)
values ('cuentas_trigger', 'cuentas', 'cuentas', 1, 1, 1, current_timestamp, current_timestamp);
insert into sym_trigger (trigger_id, source_table_name, channel_id, sync_on_update, sync_on_insert, sync_on_delete, last_update_time, create_time)
values ('movimientos_trigger', 'movimientos', 'movimientos', 1, 1, 1, current_timestamp, current_timestamp);
insert into sym_trigger (trigger_id, source_table_name, channel_id, sync_on_update, sync_on_insert, sync_on_delete, last_update_time, create_time, source_node_group_id)
values ('auditorias_trigger', 'auditorias', 'auditorias', 1, 1, 1, current_timestamp, current_timestamp, 'trans'); -- <-- SOLO SE CREA EN EL GRUPO 'trans'
insert into sym_trigger (trigger_id, source_table_name, channel_id, sync_on_update, sync_on_insert, sync_on_delete, last_update_time, create_time)
values ('sucursales_trigger', 'sucursales', 'sucursales', 1, 1, 1, current_timestamp, current_timestamp);

-- Habilitar replicación en cascada para que los datos que llegan al master se re-envíen
UPDATE sym_trigger SET sync_on_incoming_batch = 1 WHERE trigger_id IN ('cuentas_trigger', 'auditorias_trigger');

-- Routers (cómo dirigir los datos)
insert into sym_router (router_id, source_node_group_id, target_node_group_id, create_time, last_update_time)
values ('master_to_trans', 'master', 'trans', current_timestamp, current_timestamp);
insert into sym_router (router_id, source_node_group_id, target_node_group_id, create_time, last_update_time)
values ('master_to_readonly', 'master', 'readonly', current_timestamp, current_timestamp);
insert into sym_router (router_id, source_node_group_id, target_node_group_id, create_time, last_update_time)
values ('trans_to_master', 'trans', 'master', current_timestamp, current_timestamp);

-- Enlazar Triggers con Routers
-- Clientes: Master -> Trans, Master -> Readonly
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('clientes_trigger', 'master_to_trans', 100, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('clientes_trigger', 'master_to_readonly', 100, current_timestamp, current_timestamp);

-- Cuentas: Master <-> Trans, Master -> Readonly
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('cuentas_trigger', 'master_to_trans', 100, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('cuentas_trigger', 'master_to_readonly', 100, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('cuentas_trigger', 'trans_to_master', 100, current_timestamp, current_timestamp);

-- Movimientos: Master <-> Trans (NO va a Readonly)
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('movimientos_trigger', 'master_to_trans', 100, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('movimientos_trigger', 'trans_to_master', 100, current_timestamp, current_timestamp);

-- Auditorias: Trans -> Master -> Readonly
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('auditorias_trigger', 'trans_to_master', 100, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('auditorias_trigger', 'master_to_readonly', 100, current_timestamp, current_timestamp); -- Para la cascada

-- Sucursales: Replicar a todos desde master (como default)
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('sucursales_trigger', 'master_to_trans', 100, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time)
values ('sucursales_trigger', 'master_to_readonly', 100, current_timestamp, current_timestamp);