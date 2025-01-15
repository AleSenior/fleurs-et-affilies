import sql from "$lib/db";

export async function DELETE({ params }) {
    await sql`DELETE FROM hist_precio_unitario
              WHERE id_floristeria = ${params.id}
              AND cod_catalogo_floristeria = ${params.cod}
              AND fecha_fin IS NULL;`;
    return new Response(null, { status: 204 });
}