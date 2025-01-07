import sql from "$lib/db";

export async function load({ url }) {
    const q: string = url.searchParams.get('q')||'';
    const res = await sql`select floristeria.id frs_id,
                                 floristeria.nombre frs_nom,
	                             catalogo_floristeria.nombre cat_nom,
	                             catalogo_floristeria.descripcion cat_des,
	                             flor_corte.nombre_comun flr_nom,
	                             color.nombre
                          from catalogo_floristeria
                          join floristeria on
	                          floristeria.id = catalogo_floristeria.id_floristeria
                          join flor_corte on
	                          flor_corte.id = catalogo_floristeria.id_flor_corte
                          join color on
	                          color.codigo_hex = catalogo_floristeria.codigo_hex
                          where lower(floristeria.nombre) like ${'%' + q.toLowerCase() + '%'}
                          or lower(catalogo_floristeria.nombre) like ${'%' + q.toLowerCase() + '%'}
                          or lower(flor_corte.nombre_comun) like ${'%' + q.toLowerCase() + '%'}
                          or lower(color.nombre) like ${'%' + q.toLowerCase() + '%'}
                          order by cat_nom;`;
    return { res: res };
}