-- Datos fijos del módulo 3 (pedidos). Incluye los de los módulos 1 y 2.
-- Se insertan como rol de servicio.
--   Bodega 0b02 (de C2 en D1): crédito habilitado, límite 100000 céntimos,
--   plazo 15 días.

\ir datos_m2.sql

select pruebas.como_servicio();

update public.clientes_negocio
set credito_habilitado = true,
    limite_credito_centimos = 100000,
    plazo_credito_dias = 15
where id = '00000000-0000-0000-0000-000000000b02';
