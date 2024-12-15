import sql from "$lib/db";

export async function load({ url }) {
    const q: string = url.searchParams.get('q')!;
    const res = await sql`SELECT DISTINCT f.id f_id,
                          f.nombre_comun f_nm,
                          f.genero_especie f_ge,
                          f.etimologia f_et,
                          f.colores f_cl,
                          f.temp_conserv_celcius f_tm
                          FROM flor_corte f
                          JOIN enlace e ON e.id_flor_corte = f.id
                          JOIN significado s ON s.id = e.id_significado
                          WHERE LOWER(f.nombre_comun) LIKE ${'%' + q.toLowerCase() + '%'}
                          OR LOWER(f.genero_especie) LIKE ${'%' + q.toLowerCase() + '%'}
                          OR LOWER(s.descripcion) LIKE ${'%' + q.toLowerCase() + '%'};`;
    return { res: res };
}