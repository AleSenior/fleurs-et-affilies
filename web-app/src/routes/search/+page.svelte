<script>
    let { data } = $props();
</script>


{#each data.res as { f_id, f_nm, f_ge, f_et, f_cl, f_tm }}
    <div class="m-4 px-4 py-3 bg-gray-200 flex flex-row justify-between items-center">
        <div class="flex flex-col justify-center object-fill">
            <p><strong>{f_nm}</strong></p>
            <p>Género: {f_ge}</p>
            <p>Etimología: {f_et}</p>
            <p>Colores: {f_cl}</p>
            <p>Temperatura (°C): {f_tm}</p>
        </div>
        <button class="h-1/2 bg-white border-2 border-gray-500 rounded-full px-5 py-2 mt-4 ml-2 hover:bg-gray-300 active:bg-gray-400">Buscar en tiendas</button>
    </div>
{/each}
