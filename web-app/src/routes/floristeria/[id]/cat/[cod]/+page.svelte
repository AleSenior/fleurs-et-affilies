<script>
    let { data } = $props();
    let newHistSwitch = $state(false);
</script>

<div class="m-4">
    <h1 class="text-6xl">{data.catalogo[0].c_nom}</h1>
    <p class="text-lg">Código: {data.catalogo[0].c_cod}</p>
    <p class="text-lg">Descripción: {data.catalogo[0].c_des}</p>
    <p class="text-lg">Flor: {data.catalogo[0].f_nom}</p>
    <p class="text-lg">Color: {data.catalogo[0].l_nom} ({data.catalogo[0].l_hex})</p>
    <p class="text-lg">Tamaño de tallo: {data.catalogo[0].d_tam} cm</p>
    <p class="text-lg">Cantidad de flores: {data.catalogo[0].d_can}</p>
    <p class="text-lg">Precio de bouquet: {data.historico[0].h_pre * data.catalogo[0].d_can}</p>
</div>

<form action="?/createHist" method="post" class="m-4">
    <h2 class="my-2 text-3xl">Histórico de precios:</h2>
    <table class="w-full">
        <thead>
            <tr class="bg-gray-300 text-left w-full">
                <th>Fecha de inicio</th>
                <th>Fecha de fin</th>
                <th>Tamaño de tallo (cm)</th>
                <th>Precio por flor</th>
            </tr>
        </thead>
        <tbody>
            {#each data.historico as hist}
                <tr class="bg-gray-100 text-left w-full">
                    <td>{hist.h_ini}</td>
                    <td>{hist.h_fin}</td>
                    <td>{hist.h_tam}</td>
                    <td>{hist.h_pre}</td>
                </tr>
            {/each}
            {#if newHistSwitch}
                <tr>
                    <td><input type="date" name="ini" value={new Date().toISOString().slice(0, 10)} class="border border-gray-300 w-full px-5"></td>
                    <td>-</td>
                    <td><input type="number" name="tam" class="border border-gray-300 w-full px-5"></td>
                    <td><input type="number" name="pre" class="border border-gray-300 w-full px-5"></td>
                </tr>
                <tr>
                    <td colspan="2" class="text-center bg-gray-100"><button class="w-full bg-blue-500 text-white hover:bg-blue-600 active:bg-blue-700" onclick={() => {newHistSwitch = false}}>Cancelar</button></td>
                    <td colspan="2" class="text-center bg-gray-100"><button type="submit" class="w-full bg-blue-500 text-white hover:bg-blue-600 active:bg-blue-700">Guardar</button></td>
                </tr>
            {:else}
                <tr>
                    <td colspan="4" class="text-center bg-gray-100"><button class="w-full bg-blue-500 text-white hover:bg-blue-600 active:bg-blue-700" onclick={() => {newHistSwitch = true}}>+</button></td>
                </tr>
            {/if}
        </tbody>
    </table>
</form>

<div class="w-full flex justify-center">
    <button class="bg-blue-500 text-white rounded-full px-5 py-2 mt-4 ml-2 hover:bg-blue-600 active:bg-blue-700">Comprar bouquet</button>
    <button class="bg-blue-500 text-white rounded-full px-5 py-2 mt-4 ml-2 hover:bg-blue-600 active:bg-blue-700">Comprar flor</button>
</div>