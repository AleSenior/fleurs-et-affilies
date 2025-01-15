CREATE TABLE registros_auditoria (
    id_auditoria SERIAL PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,       -- Usuario que ejecutó la acción
    fecha_hora TIMESTAMP DEFAULT NOW(), -- Fecha y hora de la acción
    tabla_afectada VARCHAR(50),         -- Tabla afectada
    operacion VARCHAR(10),              -- Tipo de operación: INSERT, UPDATE, DELETE
    consulta TEXT,                      -- La consulta ejecutada
    datos_anteriores JSONB,             -- Datos anteriores (para UPDATE o DELETE)
    datos_nuevos JSONB                  -- Datos nuevos (para INSERT o UPDATE)
);


CREATE OR REPLACE FUNCTION trigger_auditoria()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO registros_auditoria (usuario, tabla_afectada, operacion, consulta, datos_nuevos)
        VALUES (CURRENT_USER, TG_TABLE_NAME, TG_OP, current_query(), row_to_json(NEW));
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO registros_auditoria (usuario, tabla_afectada, operacion, consulta, datos_anteriores, datos_nuevos)
        VALUES (CURRENT_USER, TG_TABLE_NAME, TG_OP, current_query(), row_to_json(OLD), row_to_json(NEW));
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO registros_auditoria (usuario, tabla_afectada, operacion, consulta, datos_anteriores)
        VALUES (CURRENT_USER, TG_TABLE_NAME, TG_OP, current_query(), row_to_json(OLD));
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER auditoria_facturas_ventas
AFTER INSERT OR UPDATE OR DELETE
ON facturas_ventas

FOR EACH ROW
EXECUTE FUNCTION trigger_auditoria();

-- Funcion para generar la factura de una venta especifica por su id
CREATE OR REPLACE FUNCTION generar_factura_venta(id_factura NUMERIC)
RETURNS TABLE(
    nombre_floristeria VARCHAR,
    email_floristeria VARCHAR,
    nombre_cliente VARCHAR,
    fecha_factura DATE,
    total_factura NUMERIC
) AS $$
DECLARE
    nombre_floristeria_local VARCHAR;
    email_floristeria_local VARCHAR;
    nombre_cliente_local VARCHAR;
    fecha_factura_local DATE;
    total_factura_local NUMERIC;
BEGIN
    -- Obtener los datos necesarios para la factura
    SELECT 
        f.nombre, 
        f.email, 
        (c.primer_nombre || ' ' || c.primer_apellido)::VARCHAR AS cliente,
        fv.fecha, 
        fv.total
    INTO 
        nombre_floristeria_local, 
        email_floristeria_local, 
        nombre_cliente_local, 
        fecha_factura_local, 
        total_factura_local
    FROM 
        facturas_ventas fv
    JOIN 
        floristerias f 
        ON fv.id_floristeria = f.id_floristeria
    JOIN 
        clientes_floristerias c
        ON fv.id_cliente_floristeria = c.id_cliente_floristeria
    WHERE 
        fv.id_factura_venta = id_factura;

    -- Verificar si la factura existe
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró la factura con ID: %', id_factura;
    END IF;

    -- Mostrar la información en formato estético
    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE '            FACTURA DE VENTA            ';
    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE 'Floristería: %', nombre_floristeria_local;
    RAISE NOTICE 'Email:       %', email_floristeria_local;
    RAISE NOTICE 'Cliente:     %', nombre_cliente_local;
    RAISE NOTICE 'Fecha:       %', fecha_factura_local;
    RAISE NOTICE 'Total:       %', total_factura_local;
    RAISE NOTICE '----------------------------------------';

    -- Retornar los datos como una tupla
    RETURN QUERY
    SELECT 
        nombre_floristeria_local, 
        email_floristeria_local, 
        nombre_cliente_local, 
        fecha_factura_local, 
        total_factura_local;
END;
$$ LANGUAGE plpgsql;

--SELECT * FROM generar_factura_venta(1);

-- Funcion para generar la factura de una venta con su detalle
CREATE OR REPLACE FUNCTION generar_factura_venta_detallada(id_factura NUMERIC)
RETURNS TABLE(
    nombre_floristeria VARCHAR,
    email_floristeria VARCHAR,
    nombre_cliente VARCHAR,
    fecha_factura DATE,
    producto_nombre VARCHAR,
    cantidad NUMERIC,
    precio_unitario NUMERIC,
    subtotal NUMERIC,
    total_factura NUMERIC
) AS $$
DECLARE
    nombre_floristeria_local VARCHAR;
    email_floristeria_local VARCHAR;
    nombre_cliente_local VARCHAR;
    fecha_factura_local DATE;
    total_factura_local NUMERIC;
    producto RECORD;
BEGIN
    -- Obtener datos generales de la factura
    SELECT 
        f.nombre, 
        f.email, 
        (c.primer_nombre || ' ' || c.primer_apellido)::VARCHAR AS cliente,
        fv.fecha, 
        fv.total
    INTO 
        nombre_floristeria_local, 
        email_floristeria_local, 
        nombre_cliente_local, 
        fecha_factura_local, 
        total_factura_local
    FROM 
        facturas_ventas fv
    JOIN 
        floristerias f 
        ON fv.id_floristeria = f.id_floristeria
    JOIN 
        clientes_floristerias c
        ON fv.id_cliente_floristeria = c.id_cliente_floristeria
    WHERE 
        fv.id_factura_venta = id_factura;

    -- Verificar si la factura existe
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró la factura con ID: %', id_factura;
    END IF;

    -- Mostrar encabezado general
    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE '          FACTURA DE VENTA DETALLADA          ';
    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE 'Floristería: %', nombre_floristeria_local;
    RAISE NOTICE 'Email:       %', email_floristeria_local;
    RAISE NOTICE 'Cliente:     %', nombre_cliente_local;
    RAISE NOTICE 'Fecha:       %', fecha_factura_local;
    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE 'DETALLE DE PRODUCTOS:';
    RAISE NOTICE '----------------------------------------';

    -- Iterar sobre los detalles de la factura y mostrar cada producto
    FOR producto IN
        SELECT 
            cf.nombre AS producto_nombre,
            dfv.cantidad,
            hpu.precio_unitario,
            (dfv.cantidad * hpu.precio_unitario) AS subtotal
        FROM 
            detalles_facturas_ventas dfv
        JOIN 
            catalogos_floristerias cf
            ON dfv.id_floristeria_cat = cf.id_floristeria AND dfv.cod_vbn_cat = cf.cod_vbn
        JOIN 
            hist_precios_unitarios hpu
            ON cf.id_floristeria = hpu.id_floristeria AND cf.cod_vbn = hpu.cod_vbn
        WHERE 
            dfv.id_factura_venta = id_factura
            AND hpu.fecha_inicio <= fecha_factura_local
            AND (hpu.fecha_fin IS NULL OR hpu.fecha_fin >= fecha_factura_local)
    LOOP
        RAISE NOTICE 'Producto: % | Cantidad: % | Precio Unitario: %.2f | Subtotal: %.2f',
            producto.producto_nombre,
            producto.cantidad,
            producto.precio_unitario,
            producto.subtotal;
    END LOOP;

    -- Mostrar pie de la factura con el total
    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE 'Total de la Factura: %.2f', total_factura_local;
    RAISE NOTICE '----------------------------------------';

    -- Retornar los datos como una tupla
    RETURN QUERY
    SELECT 
        nombre_floristeria_local, 
        email_floristeria_local, 
        nombre_cliente_local, 
        fecha_factura_local,
        cf.nombre AS producto_nombre,
        dfv.cantidad,
        hpu.precio_unitario,
        (dfv.cantidad * hpu.precio_unitario) AS subtotal,
        total_factura_local
    FROM 
        detalles_facturas_ventas dfv
    JOIN 
        catalogos_floristerias cf
        ON dfv.id_floristeria_cat = cf.id_floristeria AND dfv.cod_vbn_cat = cf.cod_vbn
    JOIN 
        hist_precios_unitarios hpu
        ON cf.id_floristeria = hpu.id_floristeria AND cf.cod_vbn = hpu.cod_vbn
    WHERE 
        dfv.id_factura_venta = id_factura
        AND hpu.fecha_inicio <= fecha_factura_local
        AND (hpu.fecha_fin IS NULL OR hpu.fecha_fin >= fecha_factura_local);
END;
$$ LANGUAGE plpgsql;

--SELECT * FROM generar_factura_venta_detallada(1);

-- Funcion para generar el cierre diario, retorna el detalle de cada factura realizada en el dia de la fecha indicado con el monto total del dia
CREATE OR REPLACE FUNCTION generar_cierre_diario(id_floristeria_param NUMERIC, fecha_cierre DATE)
RETURNS TABLE(
    id_factura NUMERIC,
    cliente VARCHAR,
    total_factura NUMERIC,
    producto_nombre VARCHAR,
    cantidad NUMERIC,
    precio_unitario NUMERIC,
    subtotal NUMERIC
) AS $$
DECLARE
    total_diario NUMERIC := 0;
    factura RECORD;
    detalle RECORD;
BEGIN
    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE '                CIERRE DIARIO              ';
    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE 'Floristería ID: %', id_floristeria_param;
    RAISE NOTICE 'Fecha: %', fecha_cierre;
    RAISE NOTICE '----------------------------------------';

    -- Iterar sobre las facturas de la floristería en la fecha dada
    FOR factura IN
        SELECT 
            fv.id_factura_venta, 
            (cf.primer_nombre || ' ' || cf.primer_apellido)::VARCHAR AS cliente,
            fv.total
        FROM 
            facturas_ventas fv
        JOIN 
            clientes_floristerias cf 
            ON fv.id_cliente_floristeria = cf.id_cliente_floristeria
        WHERE 
            fv.id_floristeria = id_floristeria_param
            AND fv.fecha = fecha_cierre
    LOOP
        -- Mostrar encabezado de la factura
        RAISE NOTICE 'Factura ID: % | Cliente: % | Total: %', 
            factura.id_factura_venta, 
            factura.cliente, 
            factura.total;

        -- Iterar sobre los detalles de la factura
        FOR detalle IN
            SELECT 
                cf.nombre AS producto_nombre,
                dfv.cantidad,
                hpu.precio_unitario,
                (dfv.cantidad * hpu.precio_unitario) AS subtotal
            FROM 
                detalles_facturas_ventas dfv
            LEFT JOIN 
                catalogos_floristerias cf
                ON dfv.id_floristeria_cat = cf.id_floristeria AND dfv.cod_vbn_cat = cf.cod_vbn
            LEFT JOIN 
                hist_precios_unitarios hpu
                ON cf.id_floristeria = hpu.id_floristeria AND cf.cod_vbn = hpu.cod_vbn
            WHERE 
                dfv.id_factura_venta = factura.id_factura_venta
                AND (hpu.fecha_inicio IS NULL OR hpu.fecha_inicio <= fecha_cierre)
                AND (hpu.fecha_fin IS NULL OR hpu.fecha_fin >= fecha_cierre)
        LOOP
            -- Mostrar detalles del producto
            RAISE NOTICE 'Producto: % | Cantidad: % | Precio Unitario: % | Subtotal: %',
                COALESCE(detalle.producto_nombre, 'N/A'),
                COALESCE(detalle.cantidad, 0),
                COALESCE(detalle.precio_unitario, 0),
                COALESCE(detalle.subtotal, 0);

            -- Retornar cada detalle como una fila en la salida de la función
            RETURN QUERY SELECT 
                factura.id_factura_venta,
                factura.cliente,
                factura.total,
                COALESCE(detalle.producto_nombre, NULL)::VARCHAR,
                COALESCE(detalle.cantidad, NULL)::NUMERIC,
                COALESCE(detalle.precio_unitario, NULL)::NUMERIC,
                COALESCE(detalle.subtotal, NULL)::NUMERIC;
        END LOOP;

        -- Si la factura no tiene detalles, devolver la factura con valores NULL para los detalles
        IF NOT FOUND THEN
            RETURN QUERY SELECT 
                factura.id_factura_venta,
                factura.cliente,
                factura.total,
                NULL::VARCHAR AS producto_nombre,
                NULL::NUMERIC AS cantidad,
                NULL::NUMERIC AS precio_unitario,
                NULL::NUMERIC AS subtotal;
        END IF;

        -- Sumar el total de la factura al total diario
        total_diario := total_diario + factura.total;

        RAISE NOTICE '----------------------------------------';
    END LOOP;

    -- Mostrar el total generado en el día
    RAISE NOTICE 'TOTAL GENERADO EN EL DÍA: %', total_diario;
    RAISE NOTICE '----------------------------------------';
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM generar_cierre_diario(1, '2024-01-15');


-- Funcion para retornar las valoraciones de un cliente especifico
CREATE OR REPLACE FUNCTION obtener_valoraciones_cliente(id_cliente NUMERIC)
RETURNS TABLE(
    nombre_producto VARCHAR,
    nombre_floristeria VARCHAR,
    valor_calidad NUMERIC,
    valor_precio NUMERIC,
    promedio NUMERIC,
    nombre_cliente VARCHAR
) AS $$
DECLARE
    detalle RECORD;
    hay_resultados BOOLEAN := FALSE; -- Bandera para verificar si hay resultados
    nombre_cliente_local VARCHAR; -- Variable para almacenar el nombre del cliente
BEGIN
    -- Obtener el nombre del cliente antes de procesar
    SELECT (primer_nombre || ' ' || primer_apellido)::VARCHAR
    INTO nombre_cliente_local
    FROM clientes_floristerias
    WHERE id_cliente_floristeria = id_cliente;

    -- Verificar si el cliente existe
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró el cliente con ID: %', id_cliente;
    END IF;

    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE '          VALORACIONES DEL CLIENTE       ';
    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE 'Cliente: %', nombre_cliente_local;
    RAISE NOTICE '----------------------------------------';

    -- Iterar sobre los detalles de facturas del cliente
    FOR detalle IN
        SELECT 
            cf.nombre AS producto,
            f.nombre AS floristeria,
            dfv.valor_calidad,
            dfv.valor_precio,
            dfv.promedio,
            nombre_cliente_local AS cliente -- Usamos el nombre del cliente ya obtenido
        FROM 
            facturas_ventas fv
        JOIN 
            detalles_facturas_ventas dfv 
            ON fv.id_factura_venta = dfv.id_factura_venta
        JOIN 
            catalogos_floristerias cf 
            ON dfv.id_floristeria_cat = cf.id_floristeria AND dfv.cod_vbn_cat = cf.cod_vbn
        JOIN 
            floristerias f 
            ON fv.id_floristeria = f.id_floristeria
        WHERE 
            fv.id_cliente_floristeria = id_cliente
    LOOP
        -- Activar la bandera porque se encontraron resultados
        hay_resultados := TRUE;

        -- Mostrar por consola cada valoración (sin repetir el nombre del cliente)
        RAISE NOTICE 'Producto: % | Floristería: % | Calidad: % | Precio: % | Promedio: %',
            detalle.producto,
            detalle.floristeria,
            detalle.valor_calidad,
            detalle.valor_precio,
            detalle.promedio;

        -- Retornar cada detalle como fila en la salida de la función
        RETURN QUERY SELECT 
            detalle.producto,
            detalle.floristeria,
            detalle.valor_calidad,
            detalle.valor_precio,
            detalle.promedio,
            detalle.cliente; -- Mantenemos el cliente en la tabla devuelta
    END LOOP;

    -- Si no hay resultados, mostrar mensaje
    IF NOT hay_resultados THEN
        RAISE NOTICE 'No se encontraron valoraciones para el cliente con ID: %', id_cliente;
    END IF;

    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE '         FIN DE LAS VALORACIONES         ';
    RAISE NOTICE '----------------------------------------';
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM obtener_valoraciones_cliente(1);

-- Funcion que retorna la valoracion promedio de cada producto comprado por el cliente
CREATE OR REPLACE FUNCTION promedio_valoraciones_cliente(id_cliente NUMERIC)
RETURNS TABLE(
    nombre_producto VARCHAR,
    nombre_floristeria VARCHAR,
    promedio_calidad NUMERIC,
    promedio_precio NUMERIC,
    promedio_general NUMERIC
) AS $$
DECLARE
    detalle RECORD;
    hay_resultados BOOLEAN := FALSE; -- Bandera para verificar si hay resultados
    nombre_cliente_local VARCHAR; -- Variable para almacenar el nombre del cliente
BEGIN
    -- Obtener el nombre del cliente antes de procesar
    SELECT (primer_nombre || ' ' || primer_apellido)::VARCHAR
    INTO nombre_cliente_local
    FROM clientes_floristerias
    WHERE id_cliente_floristeria = id_cliente;

    -- Verificar si el cliente existe
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró el cliente con ID: %', id_cliente;
    END IF;

    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE '        PROMEDIO DE VALORACIONES DEL CLIENTE       ';
    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE 'Cliente: %', nombre_cliente_local;
    RAISE NOTICE '----------------------------------------';

    -- Iterar sobre los promedios de valoraciones agrupados por producto y floristería
    FOR detalle IN
        SELECT 
            cf.nombre AS producto,
            f.nombre AS floristeria,
            AVG(dfv.valor_calidad) AS promedio_calidad,
            AVG(dfv.valor_precio) AS promedio_precio,
            AVG(dfv.promedio) AS promedio_general
        FROM 
            facturas_ventas fv
        JOIN 
            detalles_facturas_ventas dfv 
            ON fv.id_factura_venta = dfv.id_factura_venta
        JOIN 
            catalogos_floristerias cf 
            ON dfv.id_floristeria_cat = cf.id_floristeria AND dfv.cod_vbn_cat = cf.cod_vbn
        JOIN 
            floristerias f 
            ON fv.id_floristeria = f.id_floristeria
        WHERE 
            fv.id_cliente_floristeria = id_cliente
        GROUP BY 
            cf.nombre, f.nombre
    LOOP
        -- Activar la bandera porque se encontraron resultados
        hay_resultados := TRUE;

        -- Mostrar por consola el promedio de valoraciones para cada producto
        RAISE NOTICE 'Producto: % | Floristería: % | Promedio Calidad: % | Promedio Precio: % | Promedio General: %',
            detalle.producto,
            detalle.floristeria,
            detalle.promedio_calidad,
            detalle.promedio_precio,
            detalle.promedio_general;

        -- Retornar cada promedio como fila en la salida de la función
        RETURN QUERY SELECT 
            detalle.producto,
            detalle.floristeria,
            detalle.promedio_calidad,
            detalle.promedio_precio,
            detalle.promedio_general;
    END LOOP;

    -- Si no hay resultados, mostrar mensaje
    IF NOT hay_resultados THEN
        RAISE NOTICE 'No se encontraron valoraciones para el cliente con ID: %', id_cliente;
    END IF;

    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE '        FIN DE LOS PROMEDIOS DE VALORACIONES         ';
    RAISE NOTICE '----------------------------------------';
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM promedio_valoraciones_cliente(1);


-- Funcion que retorna los promedios de cada producto de una floristeria
CREATE OR REPLACE FUNCTION promedio_productos_floristeria_detalle(id_floristeria_param NUMERIC)
RETURNS TABLE(
    nombre_producto VARCHAR,
    promedio_calidad NUMERIC,
    promedio_precio NUMERIC,
    promedio_general NUMERIC
) AS $$
DECLARE
    detalle RECORD;
    hay_resultados BOOLEAN := FALSE; -- Bandera para verificar si hay resultados
    nombre_floristeria_local VARCHAR; -- Variable para almacenar el nombre de la floristería
BEGIN
    -- Obtener el nombre de la floristería antes de procesar
    SELECT f.nombre
    INTO nombre_floristeria_local
    FROM floristerias f
    WHERE f.id_floristeria = id_floristeria_param; -- Usar alias para el parámetro

    -- Verificar si la floristería existe
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró la floristería con ID: %', id_floristeria_param;
    END IF;

    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE '     PROMEDIO DE PRODUCTOS POR FLORISTERÍA     ';
    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE 'Floristería: %', nombre_floristeria_local;
    RAISE NOTICE '----------------------------------------';

    -- Iterar sobre los promedios agrupados por producto
    FOR detalle IN
        SELECT 
            cf.nombre AS producto,
            AVG(dfv.valor_calidad) AS promedio_calidad,
            AVG(dfv.valor_precio) AS promedio_precio,
            AVG(dfv.promedio) AS promedio_general
        FROM 
            detalles_facturas_ventas dfv
        JOIN 
            catalogos_floristerias cf 
            ON dfv.id_floristeria_cat = cf.id_floristeria AND dfv.cod_vbn_cat = cf.cod_vbn
        WHERE 
            cf.id_floristeria = id_floristeria_param -- Usar alias para el parámetro
        GROUP BY 
            cf.nombre
    LOOP
        -- Activar la bandera porque se encontraron resultados
        hay_resultados := TRUE;

        -- Mostrar por consola el promedio de valoraciones para cada producto
        RAISE NOTICE 'Producto: % | Promedio Calidad: % | Promedio Precio: % | Promedio General: %',
            detalle.producto,
            detalle.promedio_calidad,
            detalle.promedio_precio,
            detalle.promedio_general;

        -- Retornar cada promedio como fila en la salida de la función
        RETURN QUERY SELECT 
            detalle.producto,
            detalle.promedio_calidad,
            detalle.promedio_precio,
            detalle.promedio_general;
    END LOOP;

    -- Si no hay resultados, mostrar mensaje
    IF NOT hay_resultados THEN
        RAISE NOTICE 'No se encontraron productos valorados para la floristería con ID: %', id_floristeria_param;
    END IF;

    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE '     FIN DEL PROMEDIO DE PRODUCTOS     ';
    RAISE NOTICE '----------------------------------------';
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM promedio_productos_floristeria_detalle(1);


-- Funcion que retorna el promedio general de todos los productos de una floristeria
CREATE OR REPLACE FUNCTION promedio_productos_floristeria(id_floristeria_param NUMERIC)
RETURNS TABLE(
    promedio_calidad NUMERIC,
    promedio_precio NUMERIC,
    promedio_general NUMERIC
) AS $$
DECLARE
    nombre_floristeria_local VARCHAR; -- Variable para almacenar el nombre de la floristería
BEGIN
    -- Obtener el nombre de la floristería antes de procesar
    SELECT f.nombre
    INTO nombre_floristeria_local
    FROM floristerias f
    WHERE f.id_floristeria = id_floristeria_param;

    -- Verificar si la floristería existe
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró la floristería con ID: %', id_floristeria_param;
    END IF;

    -- Calcular los promedios de todas las valoraciones para la floristería
    RETURN QUERY
    SELECT 
        AVG(dfv.valor_calidad) AS promedio_calidad,
        AVG(dfv.valor_precio) AS promedio_precio,
        AVG(dfv.promedio) AS promedio_general
    FROM 
        detalles_facturas_ventas dfv
    JOIN 
        catalogos_floristerias cf 
        ON dfv.id_floristeria_cat = cf.id_floristeria AND dfv.cod_vbn_cat = cf.cod_vbn
    WHERE 
        cf.id_floristeria = id_floristeria_param;

    -- Mostrar los promedios en formato de mensaje
    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE '       PROMEDIO GENERAL DE PRODUCTOS     ';
    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE 'Floristería: %', nombre_floristeria_local;
    RAISE NOTICE '----------------------------------------';

    FOR promedio_calidad, promedio_precio, promedio_general IN 
        SELECT 
            AVG(dfv.valor_calidad) AS promedio_calidad,
            AVG(dfv.valor_precio) AS promedio_precio,
            AVG(dfv.promedio) AS promedio_general
        FROM 
            detalles_facturas_ventas dfv
        JOIN 
            catalogos_floristerias cf 
            ON dfv.id_floristeria_cat = cf.id_floristeria AND dfv.cod_vbn_cat = cf.cod_vbn
        WHERE 
            cf.id_floristeria = id_floristeria_param
    LOOP
        -- Mostrar promedios en el mensaje
        RAISE NOTICE 'Promedio Calidad: % | Promedio Precio: % | Promedio General: %',
            promedio_calidad,
            promedio_precio,
            promedio_general;
    END LOOP;

    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE '      FIN DEL PROMEDIO GENERAL         ';
    RAISE NOTICE '----------------------------------------';
END;
$$ LANGUAGE plpgsql;





-- SELECT * FROM promedio_productos_floristeria(1);


--------------------------------------------------------- Seguridad ----------------------------------------------------------

--1. Gerente Floristería
--Este rol tiene acceso completo a las operaciones de la floristería, con permisos amplios para las tablas mencionadas.
-- Creación del rol
CREATE ROLE gerente_floristeria;
-- Permisos para las tablas
GRANT SELECT, INSERT, UPDATE, DELETE ON floristerias, catalogos_floristerias, hist_precios_unitarios, facturas_ventas, detalles_facturas_ventas, detalles_bouquets, personales, clientes_floristerias TO gerente_floristeria;
-- Permisos para procedimientos y funciones
GRANT EXECUTE ON FUNCTION generar_cierre_diario, generar_factura_venta, generar_factura_venta_detallada, obtener_valoraciones_cliente, promedio_productos_floristeria, promedio_productos_floristeria_detalle, promedio_valoraciones_cliente TO gerente_floristeria;

--2. Cajero Floristería
--Este rol se limita a trabajar en las áreas de ventas y generación de reportes.
-- Creación del rol
CREATE ROLE cajero_floristeria;
-- Permisos para las tablas
GRANT SELECT, INSERT ON facturas_ventas, clientes_floristerias, detalles_facturas_ventas TO cajero_floristeria;
GRANT SELECT ON floristerias TO cajero_floristeria;
GRANT SELECT ON catalogos_floristerias TO cajero_floristeria;
GRANT EXECUTE ON FUNCTION generar_cierre_diario, generar_factura_venta, generar_factura_venta_detallada, obtener_valoraciones_cliente, promedio_productos_floristeria, promedio_productos_floristeria_detalle, promedio_valoraciones_cliente TO cajero_floristeria;


--3. Encargado Catálogo Floristería
--Este rol administra el catálogo de la floristería.
-- Creación del rol
CREATE ROLE encargado_catalogo_floristeria;
-- Permisos para las tablas
GRANT SELECT, INSERT, UPDATE, DELETE ON catalogos_floristerias, hist_precios_unitarios, detalles_bouquets TO encargado_catalogo_floristeria;

--4. RRHH Floristería
--Este rol gestiona el personal de la floristería.
-- Creación del rol
CREATE ROLE rrhh_floristeria;
-- Permisos para las tablas
GRANT SELECT, INSERT, UPDATE, DELETE ON personales TO rrhh_floristeria;

--5. Encargado Subastadora
--Este rol gestiona contratos, afiliaciones y operaciones de la subastadora.
-- Creación del rol
CREATE ROLE encargado_subastadora;
-- Permisos para las tablas
GRANT SELECT, INSERT, UPDATE, DELETE ON subastadoras, contratos, detalles_contratos, lotes, pagos, facturas_compras, afiliaciones TO encargado_subastadora;

--6. Encargado Catálogo Productor
--Este rol se encarga del catálogo de los productores.
-- Creación del rol
CREATE ROLE encargado_catalogo_productor;
-- Permisos para las tablas
GRANT SELECT, INSERT, UPDATE, DELETE ON catalogos_productores, flores_cortes, colores_flores, enlaces, significados TO encargado_catalogo_productor;

--7. Gerente Productor
--Este rol gestiona al productor y su catálogo.
-- Creación del rol
CREATE ROLE gerente_productor;
-- Permisos para las tablas
GRANT SELECT, INSERT, UPDATE, DELETE ON productores, catalogos_productores TO gerente_productor;

--8. DBA
--El rol DBA tiene acceso total a todas las operaciones en la base de datos.
-- Crear el rol DBA
CREATE ROLE dba
WITH
    LOGIN
    SUPERUSER
    CREATEDB
    CREATEROLE
    INHERIT
    NOREPLICATION
    CONNECTION LIMIT -1;

--9. Auditor de la Base de Datos
--Este rol se usa para monitorear la actividad y realizar auditorías. Tiene acceso limitado a las tablas y vistas relacionadas con logs y estadísticas.
-- Creación del rol
CREATE ROLE auditor;
-- Permisos para vistas estadísticas
GRANT SELECT ON pg_stat_activity, pg_stat_database, pg_stat_replication TO auditor;
-- Permisos para consultar tablas de logs y auditorías (si existen)
GRANT SELECT ON registros_auditoria TO auditor;
REVOKE INSERT, UPDATE, DELETE ON registros_auditoria FROM auditor;
REVOKE ALL ON FUNCTION trigger_auditoria FROM PUBLIC;
GRANT EXECUTE ON FUNCTION trigger_auditoria TO dba;

--Crear usuarios y asignarles roles:

--------------------- Gerente floristeria ---------------------------------------------
CREATE USER usuario_gerente_floristeria WITH PASSWORD 'password';
GRANT gerente_floristeria TO usuario_gerente_floristeria;

--Ejemplo autorizado
SELECT * FROM generar_cierre_diario(1);
select * from floristerias;
--Ejemplo no autorizado
select * from contratos;

--------------------- Cajero floristeria ---------------------------------------------
CREATE USER usuario_cajero_floristeria WITH PASSWORD 'password';
GRANT cajero_floristeria TO usuario_cajero_floristeria;

--Ejemplo autorizado
SELECT * FROM generar_cierre_diario(1);
select * from facturas_ventas;
--Ejemplo no autorizado
select * from contratos;
--------------------- Encargado catalogo floristeria --------------------------
CREATE USER usuario_encargado_catalogo_floristeria WITH PASSWORD 'password';
GRANT encargado_catalogo_floristeria TO usuario_encargado_catalogo_floristeria;

--Ejemplo autorizado
select * from catalogos_floristerias;
select * from hist_precios_unitarios;
--Ejemplo no autorizado
SELECT * FROM generar_cierre_diario(1);
--------------------- rrhh floristeria --------------------------
CREATE USER usuario_rrhh_floristeria WITH PASSWORD 'password';
GRANT rrhh_floristeria TO usuario_rrhh_floristeria;
--Ejemplo autorizado
select * from personales;
--Ejemplo no autorizado
select * from hist_precios_unitarios;
SELECT * FROM generar_cierre_diario(1);
--------------------- Encargado subastadora --------------------------
CREATE USER usuario_encargado_subastadora WITH PASSWORD 'password';
GRANT encargado_subastadora TO usuario_encargado_subastadora;
--Ejemplo autorizado
select * from subastadoras;
select * from lotes;
--Ejemplo no autorizado
SELECT * FROM generar_cierre_diario(1);
--------------------- Encargado catalogo productor --------------------------
CREATE USER usuario_encargado_catalogo_productor WITH PASSWORD 'password';
GRANT encargado_catalogo_productor TO usuario_encargado_catalogo_productor;
--Ejemplo autorizado
select * from catalogos_productores;
select * from enlaces;
--Ejemplo no autorizado
SELECT * FROM generar_cierre_diario(1);
--------------------- Gerente productor --------------------------
CREATE USER usuario_gerente_productor WITH PASSWORD 'password';
GRANT gerente_productor TO usuario_gerente_productor;
--Ejemplo autorizado
select * from productores;
select * from catalogos_productores;
--Ejemplo no autorizado
SELECT * FROM generar_cierre_diario(1);
--------------------- DBA --------------------------
CREATE USER dba_user
WITH
    PASSWORD 'password';
-- Asignar el rol DBA al usuario
GRANT dba TO dba_user;
GRANT CONNECT ON DATABASE "DB NAME" TO dba;
--------------------- Auditor --------------------------
CREATE USER auditor_user WITH PASSWORD 'password';
GRANT auditor TO auditor_user;
