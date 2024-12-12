<script lang="ts">
	import '../app.css';
	let { children } = $props();
</script>

<nav class="flex bg-gray-200 py-2">
	<div>
		<a href="/" class="ml-4 underline hover:cursor-pointer">Buscar</a>
		<a href="/about" class="ml-4 underline hover:cursor-pointer">About</a>
	</div>
</nav>

{@render children()}