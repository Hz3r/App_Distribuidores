begin;
select pruebas.afirma(auth.uid() is null, '0.1 sin sesión no hay uid');
select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select pruebas.afirma(auth.uid() = '00000000-0000-0000-0000-0000000000a1', '0.2 como() fija el uid');
select pruebas.afirma(current_user = 'authenticated', '0.3 como() cambia de rol');
select pruebas.espera_error('select 1/0', '22012', '0.4 espera_error captura el sqlstate');
select pruebas.como_servicio();
select pruebas.afirma(current_user <> 'authenticated', '0.5 como_servicio() restaura el rol');
rollback;
