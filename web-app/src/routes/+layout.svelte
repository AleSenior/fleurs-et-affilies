<script lang="ts">
	import '../app.css';
	let { children } = $props();
</script>

<nav class="flex bg-gray-200 py-2 sticky top-0 w-full">
	<div>
		<a href="/" class="ml-4 underline hover:cursor-pointer">Buscar</a>
	</div>
</nav>

{@render children()}