import sql from "$lib/db";

export async function load({ params, url }) {
    const mes = url.searchParams.get('mes')||(new Date().getFullYear()+1).toString()+'-'+new Date().getMonth().toString();
    let mesConDia = mes+'-01';
    const floristeria = await sql`select f.id f_id,
                                 f.nombre f_nom,
                                 f.email f_eml,
                                 f.pagina_web f_web
                          from floristeria f
                          where f.id = ${Number.parseInt(params.id)};`;
    const catalogo = await sql`select c.codigo c_cod,
                                 c.nombre c_nom,
                                 c.descripcion c_des,
                                 f.nombre_comun f_nom,
                                 l.codigo_hex l_hex,
                                 l.nombre l_nom
                          from catalogo_floristeria c
                          join flor_corte f on
                            f.id = c.id_flor_corte
                          join color l on
                            l.codigo_hex = c.codigo_hex
                          where c.id_floristeria = ${Number.parseInt(params.id)};`;
    const balance = await sql`select 'Venta' fac_con,
                                     fv.id fac_num,
                                     to_char(fv.fecha, 'DD/MM/YYYY') fac_fec,
                                     fv.monto_total fac_ing,
                                     null fac_egr,
                                     '-' fac_env
                              from factura_venta_cab fv
                              where fv.id_floristeria = ${Number.parseInt(params.id)}
                              and date_trunc('month', fv.fecha)::date = date_trunc('month', to_date(${mesConDia}, 'YYYY-MM-DD'))::date
                              union all
                              select 'Compra' fac_con,
                                     fc.id fac_num,
                                     to_char(fc.fecha, 'DD/MM/YYYY') fac_fec,
                                     null fac_ing,
                                     fc.monto_total fac_egr,
                                     case when fc.envio then 'Si' else 'No' end fac_env
                              from factura_compra fc
                              where fc.id_floristeria = ${Number.parseInt(params.id)}
                              and date_trunc('month', fc.fecha)::date = date_trunc('month', to_date(${mesConDia}, 'YYYY-MM-DD'))::date
                              order by fac_fec;`;
    const total = await sql `select sum(fac.monto_total) total
                             from (select fv.monto_total
                                   from factura_venta_cab fv
                                   where fv.id_floristeria = ${Number.parseInt(params.id)}
                                   and date_trunc('month', fv.fecha)::date = date_trunc('month', to_date(${mesConDia}, 'YYYY-MM-DD'))::date
                                   union all
                                   select -fc.monto_total
                                   from factura_compra fc
                                   where fc.id_floristeria = ${Number.parseInt(params.id)}
                                   and date_trunc('month', fc.fecha)::date = date_trunc('month', to_date(${mesConDia}, 'YYYY-MM-DD'))::date) fac;`;
    return { floristeria: floristeria,
             catalogo: catalogo,
             balance: balance,
             total: total,
             mes: mes
     };
}