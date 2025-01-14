import sql from "$lib/db";

export async function load({ params }) {
    const catalogo = await sql`select c.codigo c_cod,
                                 c.nombre c_nom,
                                 c.descripcion c_des,
                                 f.nombre_comun f_nom,
                                 l.codigo_hex l_hex,
                                 l.nombre l_nom,
                                 d.id d_id,
                                 d.cantidad d_can,
                                 d.tam_tallo_cm d_tam
                          from catalogo_floristeria c
                          join flor_corte f on
                            f.id = c.id_flor_corte
                          join color l on
                            l.codigo_hex = c.codigo_hex
                          join det_bouquet d on
                            c.id_floristeria = d.id_floristeria
                            and c.codigo = d.cod_catalogo_floristeria
                          where c.id_floristeria = ${Number.parseInt(params.id)} and c.codigo = ${Number.parseInt(params.cod)};`;
    const historico = await sql`select h.tam_tallo_cm h_tam,
                                     h.precio_unitario h_pre,
                                     coalesce(to_char(h.fecha_inicio, 'DD/MM/YYYY'), '-') h_ini,
                                     coalesce(to_char(h.fecha_fin, 'DD/MM/YYYY'), '-') h_fin
                              from hist_precio_unitario h
                              where h.id_floristeria = ${Number.parseInt(params.id)} and h.cod_catalogo_floristeria = ${Number.parseInt(params.cod)}
                              order by h.fecha_inicio desc;`;
    return { catalogo: catalogo,
             historico: historico
     };
}