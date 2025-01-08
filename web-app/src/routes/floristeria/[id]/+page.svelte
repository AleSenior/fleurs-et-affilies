<script>
    let { data } = $props();
</script>

<div class="m-4">
    <h1 class="text-6xl">{data.floristeria[0].f_nom}</h1>
</div>

<form action="{data.floristeria[0].f_id}?/find" method="get" class="m-4">
    <h2 class="my-2 text-3xl">Balance:</h2>
    <table class="w-full">
        <thead class="bg-gray-300 text-left w-full">
            <tr class="w-full">
                <th>Concepto</th>
                <th>Número de factura</th>
                <th>Fecha</th>
                <th>Ingreso</th>
                <th>Egreso</th>
                <th>Envío</th>
            </tr>
        </thead>
        <tbody>
        {#if data.balance.length == 0}
            <tr class="w-full">
                <td colspan="6" class="text-center bg-gray-100">No hay facturas este mes</td>
            </tr>
        {/if}
        {#each data.balance as bal}
            <tr>
                <td>{bal.fac_con}</td>
                <td>{bal.fac_num}</td>
                <td>{bal.fac_fec}</td>
                <td>{bal.fac_ing}</td>
                <td>{bal.fac_egr}</td>
                <td>{bal.fac_env}</td>
            </tr>
        {/each}
        </tbody>
        <tfoot>
            <tr class="bg-gray-200">
                <td colspan="3">Total:</td>
                {#if data.total[0].total >= 0}
                    <td>{data.total[0].total}</td>
                    <td colspan="2"></td>
                {:else}
                    <td></td>
                    <td>{-data.total[0].total}</td>
                    <td></td>
                {/if}
            </tr>
        </tfoot>
    </table>
    <div class="w-full flex justify-center">
        <input type="month" name="mes" value={data.mes} class="border border-gray-300 w-1/2 rounded-full px-5 py-2 mt-4">
        <button type="submit" class="bg-blue-500 text-white rounded-full px-5 py-2 mt-4 ml-2 hover:bg-blue-600 active:bg-blue-700">Buscar</button>
    </div>
</form>

<div class="m-4">
    <h2 class="my-2 text-3xl">Catálogo:</h2>
    <table class="w-full">
        <thead class="bg-gray-300 text-left w-full">
            <tr class="w-full">
                <th>Código</th>
                <th>Nombre</th>
                <th>Descripción</th>
                <th>Flor</th>
                <th colspan="2">Color</th>
            </tr>
        </thead>
        <tbody>
        {#each data.catalogo as cat}
            <tr class="m-4 px-4 py-3 bg-gray-200">
                <td><strong>{cat.c_cod}</strong></td>
                <td><strong>{cat.c_nom}</strong></td>
                <td>{cat.c_des}</td>
                <td><strong>{cat.f_nom}</strong></td>
                <td>{cat.l_hex}</td>
                <td>{cat.l_nom}</td>
            </tr>
        {/each}
        </tbody>
    </table>
</div>

<div class="m-4">
    <h2 class="text-3xl">Contáctanos:</h2>
    <p class="text-lg">{data.floristeria[0].f_eml}</p>
    <p class="text-lg">{data.floristeria[0].f_web}</p>
</div>