import sql from "$lib/db";

export async function load() {
    const res = await sql`SELECT id, nombre FROM productor;`;
    return { productores: res };
}