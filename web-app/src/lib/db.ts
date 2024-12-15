import postgres from 'postgres';
import { PG_DATABASE, PG_HOST, PG_PORT, PG_USER, PG_PASSWORD } from '$env/static/private';

const sql = postgres({
    host: PG_HOST,
    port: parseInt(PG_PORT),
    username: PG_USER,
    password: PG_PASSWORD,
    database: PG_DATABASE
});

export default sql;