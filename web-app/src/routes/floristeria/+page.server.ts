import sql from "$lib/db";

export async function load() {
    const res = await sql`select f.id f_id,
                                 f.nombre f_nom,
                                 f.email f_eml,
                                 f.pagina_web f_web
                          from floristeria f;`;
    return { res: res };
}