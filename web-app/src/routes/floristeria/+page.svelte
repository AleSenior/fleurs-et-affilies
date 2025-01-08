<script>
    let { data } = $props();
</script>

{#each data.res as { f_id, f_nom, f_eml, f_web }}
    <div class="m-4 px-4 py-3 bg-gray-200 flex flex-row justify-between items-center">
        <div class="flex flex-col justify-center object-fill">
            <p><strong>{f_nom}</strong></p>
            <p>{f_eml}</p>
            <p>{f_web}</p>
        </div>
        <a href="/floristeria/{f_id}" class="h-1/2 bg-white border-2 border-gray-500 rounded-full px-5 py-2 mt-4 ml-2 hover:bg-gray-300 active:bg-gray-400">Entrar</a>
    </div>
{/each}