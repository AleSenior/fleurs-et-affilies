<script>
// @ts-nocheck

    let { data } = $props();
    
</script>
<form action="browse?/find" method="get" class="flex flex-col justify-center items-center object-fill">
    <input type="text" name="q" class="w-3/4 border border-gray-300 rounded-full px-5 py-2 mt-4" placeholder="Filtrar resultados" onkeydown={(e) => {if (e.key === 'Enter') {e.target.form.submit(); e.target.value = ''}}}>
</form>

{#each data.res as { frs_id, frs_nom, cat_nom, cat_des, flr_nom, col_nom }}
    <div class="m-4 px-4 py-3 bg-gray-200 flex flex-row justify-between items-center">
        <div class="flex flex-col justify-center object-fill">
            <p><strong>{frs_nom}</strong></p>
            <p><strong>{cat_nom}</strong></p>
            <p>{cat_des}</p>
            <p><strong>{flr_nom}</strong></p>
            <p>{col_nom}</p>
        </div>
        <a href="/floristeria/{frs_id}" class="h-1/2 bg-white border-2 border-gray-500 rounded-full px-5 py-2 mt-4 ml-2 hover:bg-gray-300 active:bg-gray-400">Entrar a floristería</a>
    </div>
{/each}