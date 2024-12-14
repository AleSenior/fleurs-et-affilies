import postgres from 'postgres';

const sql = postgres({
    host: 'localhost',
    port: 5432,
    username: 'postgres',
    password: '12345678',
    database: 'fea_db'
});

export default sql;