-----------------------------------------------------------------------
--------------- CREATES ----------------------------------------------
-----------------------------------------------------------------------


CREATE SEQUENCE seq_pais START WITH 1 INCREMENT BY 1 MINVALUE 1;

CREATE TABLE Pais (
  id NUMERIC NOT NULL DEFAULT NEXTVAL('seq_pais'),
  nombre VARCHAR(30) NOT NULL,

  CONSTRAINT PK_Pais PRIMARY KEY (id)
);

CREATE SEQUENCE seq_cliente START WITH 1 INCREMENT BY 1 MINVALUE 1;

CREATE TABLE Cliente (
  id NUMERIC NOT NULL DEFAULT NEXTVAL('seq_cliente'),
  doc_identidad VARCHAR(20) NOT NULL,
  p_nombre VARCHAR(30) NOT NULL,
  s_nombre VARCHAR(30),
  p_apellido VARCHAR(30) NOT NULL,
  s_apellido VARCHAR(30),
  genero CHAR(1) NOT NULL,
  fecha_nacimiento DATE NOT NULL,

  CONSTRAINT PK_Cliente PRIMARY KEY (id),
  CONSTRAINT Ck_Cliente_Genero CHECK (genero IN ('M', 'F'))
);

CREATE SEQUENCE seq_floristeria START WITH 1 INCREMENT BY 1 MINVALUE 1;

CREATE TABLE Floristeria (
  id NUMERIC NOT NULL DEFAULT NEXTVAL('seq_floristeria'),
  nombre VARCHAR(50) NOT NULL,
  email VARCHAR(50) NOT NULL,
  pagina_web VARCHAR(50),
  
  CONSTRAINT PK_Floristeria PRIMARY KEY (id)
);

CREATE TABLE Color (
  codigo_hex VARCHAR(6) NOT NULL,
  nombre VARCHAR(25) NOT NULL,
  descripcion VARCHAR NOT NULL,

  CONSTRAINT PK_Color PRIMARY KEY (codigo_hex)
);

CREATE SEQUENCE seq_flor_corte START WITH 1 INCREMENT BY 1 MINVALUE 1;

CREATE TABLE Flor_Corte (
  id NUMERIC NOT NULL DEFAULT NEXTVAL('seq_flor_corte'),
  nombre_comun VARCHAR(30) NOT NULL,
  genero_especie VARCHAR(40) NOT NULL,
  etimologia VARCHAR(300) NOT NULL,
  colores VARCHAR(50) NOT NULL,
  temp_conserv_celcius NUMERIC(2) NOT NULL,

  CONSTRAINT PK_Flor_Corte PRIMARY KEY (id)
);

CREATE SEQUENCE seq_casa_subastadora START WITH 1 INCREMENT BY 1 MINVALUE 1;

CREATE TABLE Casa_Subastadora (
  id NUMERIC NOT NULL DEFAULT NEXTVAL('seq_casa_subastadora'),
  nombre VARCHAR(50) NOT NULL,
  id_pais NUMERIC NOT NULL,
  
  CONSTRAINT PK_Casa_Subastadora PRIMARY KEY (id),
  CONSTRAINT FK_Casa_Subastadora_Pais FOREIGN KEY (id_pais) REFERENCES Pais (id)
);

CREATE SEQUENCE seq_productor START WITH 1 INCREMENT BY 1 MINVALUE 1;

CREATE TABLE Productor (
  id NUMERIC NOT NULL DEFAULT NEXTVAL('seq_productor'),
  nombre VARCHAR(50) NOT NULL,
  sitio_web VARCHAR(50) NOT NULL,
  dir_oficina_principal VARCHAR(150) NOT NULL,
  id_pais NUMERIC NOT NULL,
  
  CONSTRAINT PK_Productor PRIMARY KEY (id),
  CONSTRAINT FK_Productor_Pais FOREIGN KEY (id_pais) REFERENCES Pais (id)
);

CREATE SEQUENCE seq_significado START WITH 1 INCREMENT BY 1 MINVALUE 1;

CREATE TABLE Significado (
  id NUMERIC NOT NULL DEFAULT NEXTVAL('seq_significado'),
  descripcion VARCHAR(150) NOT NULL,
  tipo CHAR(1) NOT NULL,

  CONSTRAINT PK_Significado PRIMARY KEY (id),
  CONSTRAINT Ck_Significado_Tipo CHECK (tipo IN ('O', 'S'))
);

CREATE SEQUENCE seq_catalogo_floristeria START WITH 1 INCREMENT BY 1 MINVALUE 1;

CREATE TABLE Catalogo_Floristeria (
  id_floristeria NUMERIC NOT NULL,
  codigo NUMERIC NOT NULL DEFAULT NEXTVAL('seq_catalogo_floristeria'),
  nombre VARCHAR(20) NOT NULL,
  descripcion VARCHAR(50),
  id_flor_corte NUMERIC NOT NULL,
  codigo_hex VARCHAR(6) NOT NULL,

  CONSTRAINT PK_Catalogo_Floristeria PRIMARY KEY (codigo, id_floristeria),
  CONSTRAINT FK_Catalogo_Floristeria_Floristeria FOREIGN KEY (id_floristeria) REFERENCES Floristeria (id),
  CONSTRAINT FK_Catalogo_Floristeria_Flor_Corte FOREIGN KEY (id_flor_corte) REFERENCES Flor_Corte (id),
  CONSTRAINT FK_Catalogo_Floristeria_Color FOREIGN KEY (codigo_hex) REFERENCES Color (codigo_hex)
);

CREATE SEQUENCE seq_catalogo_productor START WITH 1 INCREMENT BY 1 MINVALUE 1;

CREATE TABLE Catalogo_Productor (
  id_productor NUMERIC NOT NULL,
  vbn NUMERIC NOT NULL DEFAULT NEXTVAL('seq_catalogo_productor'),
  nombre_propio VARCHAR(20) NOT NULL,
  descripcion VARCHAR(150) NOT NULL,
  id_flor_corte NUMERIC NOT NULL,

  CONSTRAINT PK_Catalogo_Productor PRIMARY KEY (vbn, id_productor),
  CONSTRAINT FK_Catalogo_Productor_Productor FOREIGN KEY (id_productor) REFERENCES Productor (id),
  CONSTRAINT FK_Catalogo_Productor_Flor_Corte FOREIGN KEY (id_flor_corte) REFERENCES Flor_Corte (id)
);

CREATE SEQUENCE seq_det_bouquet START WITH 1 INCREMENT BY 1 MINVALUE 1;

CREATE TABLE Det_Bouquet (
  id_floristeria NUMERIC NOT NULL,
  cod_catalogo_floristeria NUMERIC NOT NULL,
  id NUMERIC NOT NULL DEFAULT NEXTVAL('seq_det_bouquet'),
  tam_tallo_cm NUMERIC(3),
  cantidad NUMERIC(2) NOT NULL,
  descripcion VARCHAR(70),

  CONSTRAINT PK_Det_Bouquet PRIMARY KEY (id, cod_catalogo_floristeria, id_floristeria),
  CONSTRAINT FK_Det_Bouquet_Catalogo_Floristeria FOREIGN KEY (cod_catalogo_floristeria, id_floristeria) REFERENCES Catalogo_Floristeria (codigo, id_floristeria)
);

CREATE SEQUENCE seq_contrato_cab START WITH 1 INCREMENT BY 1 MINVALUE 1;

CREATE TABLE Contrato_CAB (
  numero NUMERIC NOT NULL DEFAULT NEXTVAL('seq_contrato_cab'),
  fecha DATE NOT NULL,
  clasificacion CHAR(2) NOT NULL,
  prod_total_pcnt NUMERIC(3) NOT NULL,
  cancelado BOOLEAN DEFAULT FALSE,
  id_casa_subastadora NUMERIC NOT NULL,
  id_productor NUMERIC NOT NULL,
  numero_contrato_original NUMERIC UNIQUE,

  CONSTRAINT PK_Contrato_CAB PRIMARY KEY (numero),
  CONSTRAINT FK_Contrato_CAB_Casa_Subastadora FOREIGN KEY (id_casa_subastadora) REFERENCES Casa_Subastadora (id),
  CONSTRAINT FK_Contrato_CAB_Productor FOREIGN KEY (id_productor) REFERENCES Productor (id),
  CONSTRAINT FK_Contrato_CAB FOREIGN KEY (numero_contrato_original) REFERENCES Contrato_CAB (numero),
  CONSTRAINT Ck_Contrato_CAB_Clasificacion CHECK (clasificacion IN ('CA', 'CB', 'CC', 'CG', 'KA')),
  CONSTRAINT Ck_Contrato_CAB_Prod_Total_Pcnt CHECK (prod_total_pcnt BETWEEN 1 AND 100)
);

CREATE TABLE Contrato_DET (
  numero_contrato_cab NUMERIC NOT NULL,
  id_productor_catalogo NUMERIC NOT NULL,
  vbn NUMERIC NOT NULL,
  cantidad NUMERIC(8) NOT NULL,

  CONSTRAINT Pk_Contrato_DET PRIMARY KEY (numero_contrato_cab, id_productor_catalogo, vbn),
  CONSTRAINT Fk_Contrato_DET_Contrato_CAB FOREIGN KEY (numero_contrato_cab) REFERENCES Contrato_CAB (numero),
  CONSTRAINT Fk_Contrato_DET_Catalogo_Productor FOREIGN KEY (id_productor_catalogo, vbn) REFERENCES Catalogo_Productor (id_productor, vbn)
);

CREATE TABLE Afiliacion_Sub_Flor (
  id_casa_subastadora NUMERIC(5) NOT NULL,
  id_floristeria NUMERIC(5) NOT NULL,
  
  CONSTRAINT PK_Afiliacion_Sub_Flor PRIMARY KEY (id_casa_subastadora, id_floristeria),
  CONSTRAINT FK_Afiliacion_Sub_Flor_Casa_Subastadora FOREIGN KEY (id_casa_subastadora) REFERENCES Casa_Subastadora (id),
  CONSTRAINT FK_Afiliacion_Sub_Flor_Floristeria FOREIGN KEY (id_floristeria) REFERENCES Floristeria (id)
);

CREATE SEQUENCE seq_factura_contrato START WITH 1 INCREMENT BY 1 MINVALUE 1;

CREATE TABLE Factura_Compra (
  id NUMERIC NOT NULL DEFAULT NEXTVAL('seq_factura_contrato'),
  fecha DATE NOT NULL,
  monto_total NUMERIC(7, 2) NOT NULL,
  envio BOOLEAN DEFAULT FALSE,
  id_casa_subastadora NUMERIC(5) NOT NULL,
  id_floristeria NUMERIC(5) NOT NULL,

  CONSTRAINT PK_Factura_Compra PRIMARY KEY (id),
  CONSTRAINT FK_Factura_Compra_Afiliacion FOREIGN KEY (id_casa_subastadora, id_floristeria) REFERENCES Afiliacion_Sub_Flor (id_casa_subastadora, id_floristeria)
);

CREATE SEQUENCE seq_lote START WITH 1 INCREMENT BY 1 MINVALUE 1;

CREATE TABLE Lote (
  numero_contrato_cab NUMERIC(8) NOT NULL,
  vbn NUMERIC(8) NOT NULL,
  id_productor_catalogo NUMERIC(5) NOT NULL,
  id NUMERIC NOT NULL DEFAULT NEXTVAL('seq_lote'),
  indice_calidad CHAR(1) NOT NULL,
  precio_inicial NUMERIC(6, 2) NOT NULL,
  precio_final NUMERIC(6, 2) NOT NULL,
  cantidad NUMERIC(6) NOT NULL,
  id_factura_compra NUMERIC(10) NOT NULL,

  CONSTRAINT Pk_Lote PRIMARY KEY (numero_contrato_cab, vbn, id_productor_catalogo, id),
  CONSTRAINT Fk_Lote_Contrato_DET FOREIGN KEY (numero_contrato_cab, vbn, id_productor_catalogo) REFERENCES Contrato_DET (numero_contrato_cab, vbn, id_productor_catalogo),
  CONSTRAINT Fk_Lote_Factura_Compra FOREIGN KEY (id_factura_compra) REFERENCES Factura_Compra (id),
  CONSTRAINT Ck_Lote_Indice_Calidad CHECK (indice_calidad IN ('A', 'B', 'C', 'D', 'E'))
);

CREATE SEQUENCE seq_factura_venta_cab START WITH 1 INCREMENT BY 1 MINVALUE 1;

CREATE TABLE Factura_Venta_CAB (
  id NUMERIC NOT NULL DEFAULT NEXTVAL('seq_factura_venta_cab'),
  fecha DATE NOT NULL,
  monto_total NUMERIC(6, 2) NOT NULL,
  id_cliente NUMERIC(8) NOT NULL,
  id_floristeria NUMERIC(5) NOT NULL,

  CONSTRAINT PK_Factura_Venta_CAB PRIMARY KEY (id),
  CONSTRAINT FK_Factura_Venta_CAB_Cliente FOREIGN KEY (id_cliente) REFERENCES Cliente (id),
  CONSTRAINT FK_Factura_Venta_CAB_Floristeria FOREIGN KEY (id_floristeria) REFERENCES Floristeria (id)
);

create sequence seq_factura_venta_det start with 1 increment by 1 minvalue 1;

CREATE TABLE Factura_Venta_DET (
  id_factura_venta_cab NUMERIC(10) NOT NULL,
  id NUMERIC NOT NULL DEFAULT NEXTVAL('seq_factura_venta_det'),
  cantidad NUMERIC(3) NOT NULL,
  valor_calidad NUMERIC(1),
  valor_precio NUMERIC(1),
  promedio NUMERIC(2,1),
  id_bouquet NUMERIC(2),
  cod_catalogo_floristeria_bouquet NUMERIC(8),
  id_floristeria_bouquet NUMERIC(5),
  cod_catalogo_floristeria NUMERIC(8),
  id_floristeria NUMERIC(5),

  CONSTRAINT PK_Factura_Venta_DET PRIMARY KEY (id_factura_venta_cab, id),
  CONSTRAINT FK_Factura_Venta_DET_Factura_Venta_CAB FOREIGN KEY (id_factura_venta_cab) REFERENCES Factura_Venta_CAB (id),
  CONSTRAINT FK_Factura_Venta_DET_Bouquet FOREIGN KEY (id_bouquet, cod_catalogo_floristeria_bouquet, id_floristeria_bouquet) REFERENCES Det_Bouquet (id, cod_catalogo_floristeria, id_floristeria),
  CONSTRAINT FK_Factura_Venta_DET_Catalogo_Floristeria FOREIGN KEY (cod_catalogo_floristeria, id_floristeria) REFERENCES Catalogo_Floristeria (codigo, id_floristeria),
  CONSTRAINT Ck_Factura_Venta_DET_Valor_Calidad CHECK (valor_calidad BETWEEN 1 AND 5),
  CONSTRAINT Ck_Factura_Venta_DET_Valor_Precio CHECK (valor_precio BETWEEN 1 AND 5),
  CONSTRAINT Ck_Factura_Venta_DET_Promedio CHECK (promedio BETWEEN 1 AND 5),
  CONSTRAINT Ck_Factura_Venta_DET_Catalogo_Bouquet CHECK ((id_bouquet IS NOT NULL AND cod_catalogo_floristeria_bouquet IS NOT NULL AND id_floristeria_bouquet IS NOT NULL AND cod_catalogo_floristeria IS NULL AND id_floristeria IS NULL) OR 
                                                          (id_bouquet IS NULL AND cod_catalogo_floristeria_bouquet IS NULL AND id_floristeria_bouquet IS NULL AND cod_catalogo_floristeria IS NOT NULL AND id_floristeria IS NOT NULL))
);

CREATE TABLE Telefono (
  prefijo NUMERIC(3) NOT NULL,
  cod_area NUMERIC(4) NOT NULL,
  numero NUMERIC(11) NOT NULL,
  tipo CHAR(1) NOT NULL,
  id_cliente NUMERIC,
  id_floristeria NUMERIC,
  id_productor NUMERIC,
  id_casa_subastadora NUMERIC,

  CONSTRAINT PK_Telefono PRIMARY KEY (prefijo, cod_area, numero),
  CONSTRAINT FK_Telefono_Cliente FOREIGN KEY (id_cliente) REFERENCES Cliente (id),
  CONSTRAINT FK_Telefono_Floristeria FOREIGN KEY (id_floristeria) REFERENCES Floristeria (id),
  CONSTRAINT FK_Telefono_Productor FOREIGN KEY (id_productor) REFERENCES Productor (id),
  CONSTRAINT FK_Telefono_Casa_Subastadora FOREIGN KEY (id_casa_subastadora) REFERENCES Casa_Subastadora (id),
  CONSTRAINT Ck_Telefono_Tipo CHECK (tipo IN ('F', 'C', 'O')),
  CONSTRAINT Ck_Propíetario CHECK (COALESCE(id_cliente/id_cliente, 0) + COALESCE(id_floristeria/id_floristeria, 0) + COALESCE(id_productor/id_productor, 0) + COALESCE(id_casa_subastadora/id_casa_subastadora, 0) = 1)
);

CREATE SEQUENCE seq_pago_multas START WITH 1 INCREMENT BY 1 MINVALUE 1;

CREATE TABLE Pagos_Multas (
  numero_contrato_cab NUMERIC(8) NOT NULL,
  id NUMERIC NOT NULL DEFAULT NEXTVAL('seq_pago_multas'),
  fecha_efectiva DATE NOT NULL,
  monto NUMERIC(6, 2) NOT NULL,
  concepto VARCHAR(3) NOT NULL,

  CONSTRAINT PK_Pagos_Multas PRIMARY KEY (id, numero_contrato_cab),
  CONSTRAINT Ck_Concepto CHECK (concepto IN ('Mem', 'Com', 'Mul')),
  CONSTRAINT FK_Pagos_Multas_Contrato_CAB FOREIGN KEY (numero_contrato_cab) REFERENCES Contrato_CAB (numero)
);

CREATE TABLE Hist_Precio_Unitario (
  id_floristeria NUMERIC NOT NULL,
  cod_catalogo_floristeria NUMERIC NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE,
  precio_unitario NUMERIC(7, 2) NOT NULL,
  tam_tallo_cm NUMERIC(3),

  CONSTRAINT PK_Hist_Precio_Unitario PRIMARY KEY (id_floristeria, cod_catalogo_floristeria, fecha_inicio),
  CONSTRAINT Fk_Hist_Precio_Unitario_Catalogo_Floristeria FOREIGN KEY (id_floristeria, cod_catalogo_floristeria) REFERENCES Catalogo_Floristeria (id_floristeria, codigo)
);

CREATE SEQUENCE seq_enlace START WITH 1 INCREMENT BY 1 MINVALUE 1;

CREATE TABLE Enlace (
  id_significado NUMERIC(4) NOT NULL,
  id NUMERIC NOT NULL DEFAULT NEXTVAL('seq_enlace'),
  descripcion VARCHAR(100),
  id_flor_corte NUMERIC(8) NOT NULL,
  codigo_hex VARCHAR(6) NOT NULL,

  CONSTRAINT PK_Enlace PRIMARY KEY (id_significado, id),
  CONSTRAINT FK_Enlace_Significado FOREIGN KEY (id_significado) REFERENCES Significado (id),
  CONSTRAINT FK_Enlace_Flor_Corte FOREIGN KEY (id_flor_corte) REFERENCES Flor_Corte (id),
  CONSTRAINT FK_Enlace_Color FOREIGN KEY (codigo_hex) REFERENCES Color (codigo_hex),
  CONSTRAINT CK_Enlace_Flor_Color CHECK (id_flor_corte IS NOT NULL OR codigo_hex IS NOT NULL)
);

CREATE SEQUENCE seq_contacto_empleado START WITH 1 INCREMENT BY 1 MINVALUE 1;

CREATE TABLE Contacto_Empleado (
  id_floristeria NUMERIC NOT NULL,
  id NUMERIC NOT NULL DEFAULT NEXTVAL('seq_contacto_empleado'),
  nombre VARCHAR(50) NOT NULL,
  apellido VARCHAR(50) NOT NULL,
  doc_identidad VARCHAR(50) NOT NULL,

  CONSTRAINT PK_Contacto_Empleado PRIMARY KEY (id_floristeria, id),
  CONSTRAINT FK_Contacto_Empleado_Floristeria FOREIGN KEY (id_floristeria) REFERENCES Floristeria (id)
);

-----------------------------------------------------------------------
--------------- TRIGGERS ----------------------------------------------
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION actualizar_monto_compra() RETURNS TRIGGER AS $calcular_monto_compra$
BEGIN
	UPDATE factura_compra
	SET monto_total = monto_total + (COALESCE(NEW.precio_final, 0) - COALESCE(OLD.precio_final, 0)) * CASE envio WHEN true THEN 1.1 ELSE 1 END
	WHERE id = COALESCE(NEW.id_factura_compra, OLD.id_factura_compra);

	RETURN NEW;
END;
$calcular_monto_compra$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER calcular_monto_compra
AFTER INSERT OR DELETE OR UPDATE OF precio_final
ON lote
FOR EACH ROW
EXECUTE FUNCTION actualizar_monto_compra();

CREATE OR REPLACE FUNCTION aum_monto_venta() RETURNS TRIGGER AS $mas_monto_venta$
BEGIN
	IF NEW.id_floristeria IS NOT NULL THEN
		UPDATE factura_venta_cab
		SET monto_total = monto_total + NEW.cantidad * (
			SELECT h.precio_unitario
			FROM catalogo_floristeria c
			JOIN hist_precio_unitario h ON (
				c.id_floristeria = h.id_floristeria AND
				c.codigo = h.cod_catalogo_floristeria AND
				h.fecha_fin IS NULL
			)
			WHERE c.id_floristeria = NEW.id_floristeria AND
				  c.codigo = NEW.cod_catalogo_floristeria
		)
		WHERE id = NEW.id_factura_venta_cab;
	ELSE
		UPDATE factura_venta_cab
		SET monto_total = monto_total + NEW.cantidad * (
			SELECT h.precio_unitario / d.cantidad
			FROM det_bouquet d
			JOIN catalogo_floristeria c ON (
				d.id_floristeria = c.id_floristeria AND
				d.cod_catalogo_floristeria = c.codigo
			)
			JOIN hist_precio_unitario h ON (
				c.id_floristeria = h.id_floristeria AND
				c.codigo = h.cod_catalogo_floristeria AND
				h.fecha_fin IS NULL
			)
			WHERE d.id_floristeria = NEW.id_floristeria_bouquet AND
				  d.cod_catalogo_floristeria = NEW.cod_catalogo_floristeria_bouquet AND
				  d.id = NEW.id_bouquet
		)
		WHERE id = NEW.id_factura_venta_cab;
	END IF;
	RETURN NEW;
END;
$mas_monto_venta$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dis_monto_venta() RETURNS TRIGGER AS $menos_monto_venta$
BEGIN
	IF OLD.id_floristeria IS NOT NULL THEN
		UPDATE factura_venta_cab
		SET monto_total = monto_total - OLD.cantidad * (
			SELECT h.precio_unitario
			FROM catalogo_floristeria c
			JOIN hist_precio_unitario h ON (
				c.id_floristeria = h.id_floristeria AND
				c.codigo = h.cod_catalogo_floristeria AND
				h.fecha_fin IS NULL
			)
			WHERE c.id_floristeria = OLD.id_floristeria AND
				  c.codigo = OLD.cod_catalogo_floristeria
		)
		WHERE id = OLD.id_factura_venta_cab;
	ELSE
		UPDATE factura_venta_cab
		SET monto_total = monto_total - OLD.cantidad * (
			SELECT h.precio_unitario / d.cantidad
			FROM det_bouquet d
			JOIN catalogo_floristeria c ON (
				d.id_floristeria = c.id_floristeria AND
				d.cod_catalogo_floristeria = c.codigo
			)
			JOIN hist_precio_unitario h ON (
				c.id_floristeria = h.id_floristeria AND
				c.codigo = h.cod_catalogo_floristeria AND
				h.fecha_fin IS NULL
			)
			WHERE d.id_floristeria = OLD.id_floristeria_bouquet AND
				  d.cod_catalogo_floristeria = OLD.cod_catalogo_floristeria_bouquet AND
				  d.id = OLD.id_bouquet
		)
		WHERE id = OLD.id_factura_venta_cab;
	END IF;
	RETURN NEW;
END;
$menos_monto_venta$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER aumentar_monto_venta
AFTER INSERT
ON factura_venta_det
FOR EACH ROW
EXECUTE FUNCTION aum_monto_venta();

CREATE OR REPLACE TRIGGER disminuir_monto_venta
AFTER DELETE
ON factura_venta_det
FOR EACH ROW
EXECUTE FUNCTION dis_monto_venta();

CREATE OR REPLACE FUNCTION validar_fechas_hist_precio_unitario()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fecha_fin IS NOT NULL AND NEW.fecha_fin < NEW.fecha_inicio THEN
        RAISE EXCEPTION 'La fecha_fin no puede ser menor a la fecha_inicio.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_fechas_trigger
BEFORE INSERT OR UPDATE ON Hist_Precio_Unitario
FOR EACH ROW
EXECUTE FUNCTION validar_fechas_hist_precio_unitario();

CREATE OR REPLACE FUNCTION validar_precios_lote()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.precio_final < NEW.precio_inicial THEN
        RAISE EXCEPTION 'El precio_final no puede ser menor al precio_inicial.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_precios_trigger
BEFORE INSERT OR UPDATE ON Lote
FOR EACH ROW
EXECUTE FUNCTION validar_precios_lote();

CREATE OR REPLACE FUNCTION verificar_renovacion_contrato() RETURNS TRIGGER AS $$
BEGIN
    -- Si el contrato es una renovación (numero_contrato_original no es NULL)
    IF NEW.numero_contrato_original IS NOT NULL THEN
        -- Verificar que el contrato original exista y no esté cancelado
        IF NOT EXISTS (
            SELECT 1
            FROM Contrato_CAB
            WHERE numero = NEW.numero_contrato_original
              AND cancelado IS NULL
        ) THEN
            RAISE EXCEPTION 'El contrato original (%), no existe o está cancelado.',
            NEW.numero_contrato_original;
        END IF;
    END IF;

    -- Si pasa las validaciones, permite la inserción
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verificar_renovacion_contrato
BEFORE INSERT ON Contrato_CAB
FOR EACH ROW
EXECUTE FUNCTION verificar_renovacion_contrato();

CREATE OR REPLACE FUNCTION validar_porcentaje_produccion() RETURNS TRIGGER AS $$ --Cambiar por un trigger de validación
BEGIN
    -- Clasificación 'CA': 50% de la producción
    IF NOT ((NEW.clasificacion = 'CA' AND NEW.prod_total_pcnt >= 50)
    -- Clasificación 'CB': entre 20% y 49% de la producción
    OR (NEW.clasificacion = 'CB' AND NEW.prod_total_pcnt BETWEEN 20 AND 49)
    -- Clasificación 'CC': 20% de la producción
    OR (NEW.clasificacion = 'CC' AND NEW.prod_total_pcnt < 20)
    -- Clasificación 'CG': Contratos con varias compañías subastadoras
    OR NEW.clasificacion = 'CG'
    -- Clasificación 'KA': 100% de la producción
    OR (NEW.clasificacion = 'KA' AND NEW.prod_total_pcnt = 100)) THEN
        RAISE EXCEPTION 'Porcentaje inválido para clasificación %', NEW.clasificacion;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_porcentaje_produccion
BEFORE INSERT OR UPDATE OF clasificacion, prod_total_pcnt
ON Contrato_CAB
FOR EACH ROW
EXECUTE FUNCTION validar_porcentaje_produccion();

CREATE OR REPLACE PROCEDURE crear_contrato(
    IN p_fecha DATE,
    IN p_clasificacion CHAR(2),
    IN p_prod_total_pcnt NUMERIC(3),
    IN p_id_casa_subastadora NUMERIC,
    IN p_id_productor NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
    -- Validación de clasificación
    IF p_clasificacion NOT IN ('CA', 'CB', 'CC', 'CG', 'KA') THEN
        RAISE EXCEPTION 'Clasificación inválida';
    END IF;

    -- Inserción
    INSERT INTO Contrato_CAB (fecha, clasificacion, prod_total_pcnt, cancelado, id_casa_subastadora, id_productor)
    VALUES (p_fecha, p_clasificacion, p_prod_total_pcnt, NULL, p_id_casa_subastadora, p_id_productor);
END;
$$;

CREATE OR REPLACE FUNCTION recomendar_flores(
    p_significado VARCHAR,
    p_color VARCHAR
) RETURNS TABLE (
    nombre_flor VARCHAR,
    descripcion VARCHAR,
    color_flor VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT fc.nombre_comun, fc.etimologia, c.nombre
    FROM Flor_Corte fc
    JOIN Enlace e ON fc.id = e.id_flor_corte
    JOIN Color c ON e.codigo_hex = c.codigo_hex
    WHERE (p_significado IS NULL OR e.descripcion = p_significado)
      AND (p_color IS NULL OR c.nombre = p_color);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generar_factura_venta_resumen(
    p_id_factura NUMERIC
) RETURNS TABLE (
    floristeria_nombre VARCHAR,
    floristeria_email VARCHAR,
    cliente_nombre_completo VARCHAR,
    fecha DATE,
    monto_total NUMERIC(7, 2)
) AS $$
DECLARE
    nombre_floristeria_local VARCHAR;
    email_floristeria_local VARCHAR;
    nombre_cliente_local VARCHAR;
    fecha_factura_local DATE;
    total_factura_local NUMERIC;
BEGIN
    SELECT
        f.nombre,
        f.email,
        CAST(c.p_nombre || ' ' || COALESCE(c.s_nombre, '') || ' ' || c.p_apellido || ' ' || COALESCE(c.s_apellido, '') AS VARCHAR) AS cliente_nombre_completo,
        fv_cab.fecha,
        fv_cab.monto_total
    INTO
        nombre_floristeria_local, 
        email_floristeria_local, 
        nombre_cliente_local, 
        fecha_factura_local, 
        total_factura_local
    FROM
        Factura_Venta_CAB fv_cab
    JOIN
        Cliente c ON fv_cab.id_cliente = c.id
    JOIN
        Floristeria f ON fv_cab.id_floristeria = f.id
    WHERE
        fv_cab.id = p_id_factura;
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

	RETURN QUERY
    SELECT 
        nombre_floristeria_local, 
        email_floristeria_local, 
        nombre_cliente_local, 
        fecha_factura_local, 
        total_factura_local;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generar_factura_venta_det(
    p_id_factura NUMERIC
) RETURNS TABLE (
    floristeria_nombre VARCHAR,
    floristeria_email VARCHAR,
    cliente_nombre_completo VARCHAR,
    fecha DATE,
    producto_nombre VARCHAR,
    cantidad NUMERIC,
    precio_unitario NUMERIC,
    subtotal NUMERIC,
    monto_total NUMERIC(7, 2)
) AS $$
DECLARE
    nombre_floristeria_local VARCHAR;
    email_floristeria_local VARCHAR;
    nombre_cliente_local VARCHAR;
    fecha_factura_local DATE;
    total_factura_local NUMERIC;
    producto RECORD;
BEGIN
    SELECT
        f.nombre,
        f.email,
        CAST(c.p_nombre || ' ' || COALESCE(c.s_nombre, '') || ' ' || c.p_apellido || ' ' || COALESCE(c.s_apellido, '') AS VARCHAR) AS cliente_nombre_completo,
        fv_cab.fecha,
        fv_cab.monto_total
    INTO
        nombre_floristeria_local, 
        email_floristeria_local, 
        nombre_cliente_local, 
        fecha_factura_local, 
        total_factura_local
    FROM
        Factura_Venta_CAB fv_cab
    JOIN
        Cliente c ON fv_cab.id_cliente = c.id
    JOIN
        Floristeria f ON fv_cab.id_floristeria = f.id
    WHERE
        fv_cab.id = p_id_factura;
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
            Factura_Venta_DET dfv
        JOIN 
            Catalogo_Floristeria cf
            ON dfv.id_floristeria = cf.id_floristeria
        JOIN 
            Hist_Precio_Unitario hpu
            ON cf.id_floristeria = hpu.id_floristeria 
        WHERE 
            dfv.id_factura_venta_cab = id_factura_venta_cab
            AND hpu.fecha_inicio <= fecha_factura_local
            AND (hpu.fecha_fin IS NULL OR hpu.fecha_fin >= fecha_factura_local)
    LOOP
        RAISE NOTICE 'Producto: % | Cantidad: % | Precio Unitario: % | Subtotal: %',
            producto.producto_nombre,
            producto.cantidad,
            producto.precio_unitario,
            producto.subtotal;
    END LOOP;

    -- Mostrar pie de la factura con el total
    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE 'Total de la Factura: %', total_factura_local;
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
        factura_venta_det dfv
    JOIN 
        catalogo_floristeria cf
        ON dfv.id_floristeria = cf.id_floristeria 
    JOIN 
        hist_precio_unitario hpu
        ON cf.id_floristeria = hpu.id_floristeria
        and cf.codigo = hpu.cod_catalogo_floristeria
    WHERE 
        dfv.id_factura_venta_cab = id_factura_venta_cab
        AND hpu.fecha_inicio = (
            SELECT MAX(h.fecha_inicio)
            FROM hist_precio_unitario h
            WHERE h.id_floristeria = hpu.id_floristeria
              AND h.cod_catalogo_floristeria = cf.codigo
              AND h.fecha_inicio <= fecha_factura_local
        );
END;
$$ LANGUAGE plpgsql;

-- Funcion para retornar las valoraciones de un cliente especifico
CREATE OR REPLACE FUNCTION obtener_valoraciones_cliente(id_cliente_v NUMERIC)
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
    SELECT (p_nombre || ' ' || p_apellido)::VARCHAR
    INTO nombre_cliente_local
    FROM Cliente
    WHERE id = id_cliente_v;

    -- Verificar si el cliente existe
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró el cliente con ID: %', id_cliente_v;
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
            Factura_Venta_CAB fv
        JOIN 
            Factura_Venta_DET dfv 
            ON fv.id = dfv.id_factura_venta_cab
        JOIN 
            Catalogo_Floristeria cf 
            ON dfv.id_floristeria = cf.id_floristeria 
        JOIN 
            Floristeria f 
            ON fv.id_floristeria = f.id
        WHERE 
            fv.id_cliente = id_cliente_v
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
        RAISE NOTICE 'No se encontraron valoraciones para el cliente con ID: %', id_cliente_v;
    END IF;

    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE '         FIN DE LAS VALORACIONES         ';
    RAISE NOTICE '----------------------------------------';
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM obtener_valoraciones_cliente(1);

-- Funcion que retorna la valoracion promedio de cada producto comprado por el cliente
CREATE OR REPLACE FUNCTION promedio_valoraciones_cliente(id_cliente_v NUMERIC)
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
    SELECT (p_nombre || ' ' || p_apellido)::VARCHAR
    INTO nombre_cliente_local
    FROM Cliente
    WHERE id = id_cliente_v;

    -- Verificar si el cliente existe
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró el cliente con ID: %', id_cliente_v;
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
            ROUND(AVG(dfv.valor_calidad),1) AS promedio_calidad,
            ROUND(AVG(dfv.valor_precio),1) AS promedio_precio,
            ROUND(AVG(dfv.promedio),1) AS promedio_general
        FROM 
            Factura_Venta_CAB fv
        JOIN 
            Factura_Venta_DET dfv 
            ON fv.id = dfv.id_factura_venta_cab
        JOIN 
            Catalogo_Floristeria cf 
            ON dfv.id_floristeria = cf.id_floristeria 
        JOIN 
            Floristeria f 
            ON fv.id_floristeria = f.id
        WHERE 
            fv.id_cliente = id_cliente_v
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
        RAISE NOTICE 'No se encontraron valoraciones para el cliente con ID: %', id_cliente_v;
    END IF;

    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE '        FIN DE LOS PROMEDIOS DE VALORACIONES         ';
    RAISE NOTICE '----------------------------------------';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generar_tabla_balance(
	p_id_floristeria NUMERIC,
	p_mes NUMERIC,
	p_ano NUMERIC
) RETURNS TABLE (
	concepto TEXT,
	numero_factura NUMERIC,
	fecha TEXT,
	ingreso NUMERIC,
	egreso NUMERIC,
	envio TEXT
) AS $$
DECLARE
	inicio_mes DATE;
BEGIN
	IF p_mes NOT BETWEEN 1 AND 12 THEN
		RAISE EXCEPTION 'Mes inválido';
	END IF;
	
	inicio_mes := REPLACE(TO_CHAR(p_ano, '0000')||'-'||TO_CHAR(p_mes, '00')||'-01', ' ', '');
	RETURN QUERY
		select 'Venta' fac_con,
				fv.id fac_num,
			 	to_char(fv.fecha, 'DD/MM/YYYY') fac_fec,
			 	fv.monto_total fac_ing,
			 	null fac_egr,
			 	'-' fac_env
	  	from factura_venta_cab fv
	  	where fv.id_floristeria = p_id_floristeria
	  	and date_trunc('month', fv.fecha)::date = inicio_mes
	  	union all
	  	select 'Compra' fac_con,
			 	fc.id fac_num,
			 	to_char(fc.fecha, 'DD/MM/YYYY') fac_fec,
			 	null fac_ing,
			 	fc.monto_total fac_egr,
			 	case when fc.envio then 'Si' else 'No' end fac_env
	  	from factura_compra fc
	  	where fc.id_floristeria = p_id_floristeria
	  	and date_trunc('month', fc.fecha)::date = inicio_mes
	  	order by fac_fec;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generar_total_balance(
	p_id_floristeria NUMERIC,
	p_mes NUMERIC,
	p_ano NUMERIC
) RETURNS NUMERIC AS $$
DECLARE
	inicio_mes DATE;
	total NUMERIC;
BEGIN
	IF p_mes NOT BETWEEN 1 AND 12 THEN
		RAISE EXCEPTION 'Mes inválido';
	END IF;
	
	inicio_mes := REPLACE(TO_CHAR(p_ano, '0000')||'-'||TO_CHAR(p_mes, '00')||'-01', ' ', '');
	select sum(fac.monto_total) total
	into total
	from (select fv.monto_total
		  from factura_venta_cab fv
		  where fv.id_floristeria = p_id_floristeria
		  and date_trunc('month', fv.fecha)::date = inicio_mes
		  union all
		  select -fc.monto_total
		  from factura_compra fc
		  where fc.id_floristeria = p_id_floristeria
		  and date_trunc('month', fc.fecha)::date = inicio_mes) fac;
	RETURN total;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generar_hist_precios(
	p_id_floristeria NUMERIC,
	p_cod_catalogo NUMERIC
) RETURNS TABLE (
	fecha_inicio TEXT,
	fecha_fin TEXT,
	tam_tallo_cm NUMERIC,
	precio_unitario NUMERIC
) AS $$
BEGIN
	RETURN QUERY
	select coalesce(to_char(h.fecha_inicio, 'DD/MM/YYYY'), '-'),
		   coalesce(to_char(h.fecha_fin, 'DD/MM/YYYY'), '-'),
		   h.tam_tallo_cm,
		   h.precio_unitario
	from hist_precio_unitario h
	where h.id_floristeria = p_id_floristeria 
	and h.cod_catalogo_floristeria = p_cod_catalogo
	order by h.fecha_inicio desc;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE pop_hist_precio(
	p_id_floristeria NUMERIC,
	p_cod_catalogo NUMERIC
) AS $$
DECLARE
	
BEGIN
    RAISE NOTICE 'Floristería: % | Catálogo: %', p_id_floristeria, p_cod_catalogo;
    
	DELETE FROM hist_precio_unitario
	WHERE id_floristeria = p_id_floristeria
	AND cod_catalogo_floristeria = p_cod_catalogo
	AND fecha_fin IS NULL;

	UPDATE hist_precio_unitario
	SET fecha_fin = NULL
	WHERE id_floristeria = p_id_floristeria
	AND cod_catalogo_floristeria = p_cod_catalogo
	AND fecha_inicio = (
		select max(h.fecha_inicio)
		from hist_precio_unitario h
		where h.id_floristeria = p_id_floristeria
		and h.cod_catalogo_floristeria = p_cod_catalogo
	);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE push_hist_precio(
	p_id_floristeria NUMERIC,
	p_cod_catalogo NUMERIC,
	p_precio_unitario NUMERIC,
	p_tam_tallo_cm NUMERIC DEFAULT NULL,
	p_fecha_inicio DATE DEFAULT CURRENT_DATE
) AS $$
DECLARE
	
BEGIN
	INSERT INTO hist_precio_unitario(id_floristeria, cod_catalogo_floristeria, fecha_inicio, fecha_fin, precio_unitario, tam_tallo_cm)
	VALUES (p_id_floristeria, p_cod_catalogo, p_fecha_inicio, NULL, p_precio_unitario, p_tam_tallo_cm);

    UPDATE hist_precio_unitario
	SET fecha_fin = p_fecha_inicio
	WHERE id_floristeria = p_id_floristeria
	AND cod_catalogo_floristeria = p_cod_catalogo
    AND fecha_inicio < p_fecha_inicio
	AND fecha_fin IS NULL;
END;
$$ LANGUAGE plpgsql;
-----------------------------------------------------------------------
--------------- INSERTS -----------------------------------------------
-----------------------------------------------------------------------

INSERT INTO Pais (nombre) VALUES
('Holanda'),
('Ecuador'),
('España'),
('USA'),
('Irlanda'),
('Mexico'),
('Australia');

INSERT INTO Cliente (doc_identidad, p_nombre, s_nombre, p_apellido, s_apellido, genero, fecha_nacimiento) VALUES
('1.716.523.170', 'Michael', NULL, 'Smith', 'Sanford', 'F', '1988-12-19'),
('NL16824662', 'Bryan', 'Jimmy', 'Morgan', 'Cummings', 'F', '1970-04-10'),
('503243265E', 'Andrea', NULL, 'Cox', 'Shaffer', 'F', '1993-07-19'),
('USA4852947', 'Devin', 'Seth', 'Olson', NULL, 'M', '1953-01-22'),
('953.753.851', 'Danny', 'Julie', 'Johnson', 'Campbell', 'M', '2005-02-14'),
('1.722.645.240', 'Joseph', NULL, 'Rivera', 'Kennedy', 'M', '1976-03-31'),
('ES27492040', 'Rebecca', 'Jennifer', 'Cook', NULL, 'F', '1945-09-13'),
('NL26951963', 'Nicole', 'Robert', 'Luna', 'Lyons', 'F', '2001-06-22'),
('USA17442119', 'Robin', NULL, 'West', 'James', 'M', '1985-06-02'),
('14.516.491.383', 'Dawn', NULL, 'Martin', NULL, 'F', '1949-04-23'),
('173.520.014', 'Ashley', NULL, 'Carter', NULL, 'F', '1985-12-13'),
('ES29152357', 'Lawrence', NULL, 'Conley', 'Gonzalez', 'M', '1965-11-05'),
('161.400.150', 'Christopher', NULL, 'Costa', NULL, 'F', '1970-07-19'),
('NL15946675', 'Charles', 'Catherine', 'Walsh', NULL, 'F', '1992-09-30'),
('USA15422244', 'Charles', NULL, 'Elliott', NULL, 'M', '1947-09-26'),
('ES15191919', 'Amanda', NULL, 'Boone', 'Holloway', 'M', '1953-07-28'),
('16482199NL', 'John', NULL, 'Carrillo', NULL, 'F', '1954-11-05'),
('USA21456654', 'Danielle', 'Miguel', 'Guerrero', 'Erickson', 'M', '1971-05-07'),
('24009751EC', 'Raymond', 'Rebecca', 'Hernandez', 'Cole', 'M', '1993-06-20'),
('16595221NL', 'Jessica', 'Frank', 'Le', NULL, 'F', '1979-09-01');

INSERT INTO Floristeria (nombre, email, pagina_web) VALUES
('Viveros Projardin', 'clientes@viverosprojardin.com', 'https://www.viverosprojardin.com/'),
('Bedford Village Flower Shoppe', 'info@bedfordvillageflowershoppe.com', 'bedfordvillageflowershoppe.com'),
('Eflorist', 'customer.services@myeflorist.com.uk', 'eflorist.ie'),
('Fleurop', 'info@flleurop.de', NULL),
('Florarte', 'info@florarte.com.mx', 'florarte.com.mx'),
('A&L Florist', 'orders@alflorist.com.au', 'https://alflorist.com.au/');

INSERT INTO Color (codigo_hex, nombre, descripcion) VALUES
('ffffff', 'blanco', 'Pureza, inocencia, la perfección, la esperanza. Las flores blancas son magníficas, únicas, y no tradicionales. Son perfectas para una nueva relación o para decir a tu pareja lo perfecta que es para ti. También son las flores para expresar la pureza de tu amor. Buenas ideas son rosas u orquídeas blancas.'),
('ff0000', 'rojo', 'El amor, la pasión, el deseo, el erotismo. El rojo es el color tradicional del amor y del romance. Una docena de rosas rojas es el clásico regalo romántico.'),
('f80000', 'rojo intenso', 'Belleza y Amor.'),
('c5388b', 'rosado', 'Romance, dulzura, alegría. Es el color femenino por excelencia. Las rosas rosadas son perfectas como regalo romántico, y representan la ingenuidad, bondad, ternura, buen sentimiento y ausencia de todo mal.'),
('ffff00', 'amarillo', 'Amistad, alegría, felicidad. Si quieres hacer las cosas más lentas es el color a enviar, el amarillo es el color de la amistad. Irradia siempre en todas partes y sobre toda las cosas, es el color de la luz.'),
('ffa500', 'naranja', 'Fascinación, el calor, la felicidad. El naranja es un color fuerte, cálido que muestra la fascinación o intriga.'),
('ffb678', 'melocoton', 'Sabiduría, gratitud, reconocimiento. El Melocotón es un tono de naranja y rosa que representan a la vez el romanticismo de las rosas y el calor y la gratitud del anaranjado. Se trata de un color perfecto para mostrar amor y reconocimiento.'),
('00ff00', 'verde', 'Armonía, la fecundidad, la riqueza. El verde es un color rico y fresco, perfecto para la pareja armoniosa. Es el color de la esperanza. Y puede expresar: naturaleza, juventud, deseo, descanso, equilibrio.'),
('0000ff', 'azul', 'La estabilidad, la confianza, tranquilidad. El Azul es el color de la paz y la estabilidad. Es fresco y relajante. Es el color del cielo y del mar. Es un color reservado y que parece que se aleja. Puede expresar confianza, reserva, armonía, afecto, amistad, fidelidad y amor.'),
('4c2882', 'violeta/lavanda', 'Es el color que indica ausencia de tensión. Puede significar: calma, autocontrol, dignidad, aristocracia. A menudo se le asocia con la nobleza, es un color perfecto para un amor de mucho tiempo.');

INSERT INTO Flor_Corte (nombre_comun, genero_especie, etimologia, colores, temp_conserv_celcius) VALUES
('Gerbera', 'Gerbera', 'Lleva el nombre de Trangott Gerber, un médico alemán que coleccionó plantas.', 'Blanco, amarillo, naranja, rojo, rosa.', '25'),
('Rosa', 'Rosa', 'Deriva del latín rosa, usado para nombrar esta flor desde la antigüedad.', 'Blanco, rojo, rosado, amarillo.', '3'),
('Tulipán', 'Tulipa', 'Del turco tülbend, que significa turbante, por la forma de la flor.', 'Rojo, amarillo, naranja, rosado.', '2'),
('Clavel', 'Dianthus', 'Del griego dios (dios) y anthos (flor), significa "la flor de los dioses".', 'Blanco, rojo, rosado, morado.', '6'),
('Girasol', 'Helianthus', 'Del griego helios (sol) y anthos (flor).', 'Amarillo.', '6'),
('Jazmín', 'Jasminum', 'Del árabe yasamin, que significa fragancia.', 'Blanco.', '5'),
('Azucena', 'Lilium candidum', 'Del latín lilium, simbolizando pureza.', 'Blanco.', '1'),
('Violeta', 'Viola', 'Del latín viola, el nombre clásico de la flor en Europa.', 'Violeta, púrpura.', '3'),
('Geranio', 'Pelargonium', 'Del griego pelargos (cigüeña), por la forma de su fruto.', 'Rojo, rosa, blanco, salmón.', '13'),
('Hortensia', 'Hydrangea', 'Deriva del griego hydor (agua) y angeion (vasija), por su forma.', 'Azul, blanco, rosa, púrpura.', '6'),
('Orquídea', 'Orchidaceae', 'Del griego orchis (testículo), por la forma de sus raíces.', 'Varios colores: blanco, rosa, púrpura.', '12'),
('Gardenia', 'Gardenia jasminoides', 'Nombrada en honor al botánico Alexander Garden.', 'Blanco.', '16'),
('Gladiolo', 'Gladiolus', 'Del latín gladius (espada), por la forma de sus hojas.', 'Blanco, rojo, rosa, amarillo, morado.', '6'),
('Guisante de olor', 'Lathyrus odoratus', 'De lathyrus (leguminosa) y odoratus (aromático).', 'Blanco, rosa, rojo, púrpura.', '5');

INSERT INTO Casa_Subastadora (nombre, id_pais) VALUES
('Hoek Flowers', 1),
('Trockenblumen Grosshabdel', 1),
('Royal FloraHolland', 1);

INSERT INTO Productor (nombre, sitio_web, dir_oficina_principal, id_pais) VALUES
('Agricola EverBloom Roses Ecuador C.L.', 'everbloomroses.com', 'Finca La Grada, calle principal s/n Barrio Jesus del gran Poder, Parroquia La Libertad, El Angel, Carchi', 2),
('Van Den Bos', 'vandenbos.com/es', 'Boswoning 106, 2675 DZ Honselersdijk Netherlands', 1),
('Rosell Vega Horticultors SL', 'rosell-vega.eu', 'Camí del Mig, 14, 18, 08320 El Masnou, Barcelona, España', 3);

INSERT INTO Significado (descripcion, tipo) VALUES
('Pureza', 'S'),
('Inocencia', 'S'),
('Perfección', 'S'),
('Amor', 'S'),
('Pasión', 'S'),
('Deseo', 'S'),
('Amistad', 'S'),
('Alegría', 'S'),
('Felicidad', 'S'),
('Sabiduría', 'S'),
('Gratitud', 'S'),
('Reconocimiento', 'S'),
('Belleza', 'S'),
('Esperanza', 'S'),
('Adoración', 'S'),
('Romance', 'S'),
('Ternura', 'S'),
('Salud', 'S'),
('Fidelidad', 'S'),
('Calma', 'S'),
('Dignidad', 'S'),
('Nobleza', 'S'),
('Armonía', 'S'),
('Sensualidad', 'S'),
('Aniversario', 'O'),
('Boda', 'O'),
('Matrimonio', 'O'),
('Funeral', 'O'),
('Velorio', 'O'),
('Desfile', 'O'),
('Graduación', 'O'),
('Hospitalización', 'O'),
('San Valenín', 'O'),
('Cumpleaños', 'O'),
('Coronación', 'O');

INSERT INTO Catalogo_Floristeria (id_floristeria, nombre, descripcion, id_flor_corte, codigo_hex) VALUES
(1, 'Rosa Aqua', 'Rosa de color rosado, símbolo de amor y ternura.', 2, 'ff0000'),
(1, 'Girasol Deluxe', 'Flor amarilla, representa adoración y vitalidad.', 5, 'ffff00'),
(2, 'Tulipán Rojo', 'Tulipán de color rojo, símbolo de amor profundo.', 3, 'ff0000'),
(2, 'Clavel Blanco', 'Clavel de color blanco, significa distinción.', 4, 'ffffff'),
(3, 'Orquídea Violeta', 'Flor elegante, símbolo de belleza y nobleza.', 11, 'c5388b'),
(3, 'Hortensia Azul', 'Hortensia de color azul, representa tranquilidad.', 10, '0000ff'),
(4, 'Jazmín Blanco', 'Jazmín de color blanco, fragancia única.', 6, 'ffffff'),
(4, 'Gerbera Mixta', 'Gerbera de varios colores, símbolo de alegría.', 1, 'ffa500'),
(5, 'Azucena Pura', 'Azucena blanca, simboliza pureza e inocencia.', 7, 'ffffff'),
(5, 'Gladiolo Rojo', 'Gladiolo rojo, destaca por su forma alargada.', 13, '4c2882'),
(6, 'Gardenia Blanca', 'Flor blanca, representa sinceridad y alegría.', 12, 'ffffff'),
(6, 'Geranio Rosa', 'Geranio rosa, ideal para expresar amistad.', 9, 'ff0000');

INSERT INTO Catalogo_Productor (id_productor, nombre_propio, descripcion, id_flor_corte) VALUES
(1, 'Gerbera Bonni', 'Gerbera de color blanco, naranja y rosa, ideal para arreglos mixtos.', 1),
(1, 'Gerbera Alistair', 'Gerbera de pétalos bicolores, muy popular en ramos vibrantes.', 1),
(2, 'Rosa Velvet', 'Rosa roja de alta calidad, símbolo de amor y romance.', 2),
(2, 'Rosa Gold', 'Rosa amarilla, destaca por su viveza y simbolismo de amistad.', 2),
(3, 'Tulipán Spring Joy', 'Tulipán de color rosado, perfecto para primavera y celebraciones.', 3),
(3, 'Tulipán Royal Red', 'Tulipán rojo intenso, clásico en arreglos elegantes.', 3),
(3, 'Clavel White Dream', 'Clavel blanco, símbolo de distinción y pureza.', 4),
(1, 'Girasol Bright Star', 'Girasol amarillo vibrante, ideal para decoraciones veraniegas.', 5);

INSERT INTO Det_Bouquet (id_floristeria, cod_catalogo_floristeria, cantidad, tam_tallo_cm, descripcion) VALUES
(1, 1, 20, 70, 'Rosa rosada, perfecta para expresar amor y dulzura.'),
(1, 2, 15, 50, 'Girasoles amarillos, ideales para decoración veraniega.'),
(2, 3, 10, 60, 'Tulipanes rojos, símbolo de amor y pasión.'),
(2, 4, 25, 40, 'Claveles blancos, representan pureza y distinción.'),
(3, 5, 12, 45, 'Orquídeas violetas, elegantes y símbolo de belleza.'),
(3, 6, 8, 50, 'Hortensias azules, perfectas para transmitir tranquilidad.'),
(4, 7, 18, 30, 'Jazmín blanco, fragancia fresca y delicada.'),
(4, 8, 20, 35, 'Gerberas mixtas, variedad colorida para ocasiones festivas.'),
(5, 9, 15, 50, 'Azucenas blancas, símbolo de inocencia y pureza.'),
(5, 10, 12, 70, 'Gladiolos rojos, con presencia fuerte y elegante.'),
(6, 11, 10, 45, 'Gardenias blancas, representan sinceridad y alegría.'),
(6, 12, 14, 40, 'Geranios rosas, ideales para expresar amistad.');

INSERT INTO Hist_Precio_Unitario (id_floristeria, cod_catalogo_floristeria, fecha_inicio, precio_unitario, fecha_fin, tam_tallo_cm) VALUES
(1, 1, '2024-11-01', 1.20, '2024-11-07', 70),
(1, 2, '2024-11-01', 0.80, '2024-11-07', 50),
(2, 3, '2024-11-02', 1.50, '2024-11-08', 60),
(2, 4, '2024-11-02', 0.90, '2024-11-08', 40),
(3, 5, '2024-11-03', 2.00, '2024-11-09', 45),
(3, 6, '2024-11-03', 1.75, '2024-11-09', 50),
(4, 7, '2024-11-04', 1.60, '2024-11-10', 30),
(4, 8, '2024-11-04', 1.25, '2024-11-10', 35),
(5, 9, '2024-11-05', 2.20, '2024-11-11', 50),
(5, 10, '2024-11-05', 2.50, '2024-11-11', 70),
(6, 11, '2024-11-06', 1.80, '2024-11-12', 45),
(6, 12, '2024-11-06', 1.40, '2024-11-12', 40),
(1, 1, '2024-11-07', 1.40, NULL, 70),
(1, 2, '2024-11-07', 1.00, NULL, 50),
(2, 3, '2024-11-08', 1.75, NULL, 60),
(2, 4, '2024-11-08', 1.15, NULL, 40),
(3, 5, '2024-11-09', 2.30, NULL, 45),
(3, 6, '2024-11-09', 2.00, NULL, 50),
(4, 7, '2024-11-10', 1.85, NULL, 30),
(4, 8, '2024-11-10', 1.50, NULL, 35),
(5, 9, '2024-11-11', 2.50, NULL, 50),
(5, 10, '2024-11-11', 2.80, NULL, 70),
(6, 11, '2024-11-12', 2.10, NULL, 45),
(6, 12, '2024-11-12', 1.65, NULL, 40);

INSERT INTO Contrato_CAB (fecha, clasificacion, prod_total_pcnt, cancelado, id_casa_subastadora, id_productor, numero_contrato_original) VALUES
('2024-01-15', 'CA', '55', NULL, 1, 1, NULL),
('2024-03-22', 'CB', '30', NULL, 2, 2, NULL),
('2024-05-10', 'CC', '15', NULL, 3, 3, NULL),
('2024-06-18', 'KA', '100', NULL, 1, 1, NULL),
('2024-08-05', 'CG', '45', NULL, 2, 2, NULL),
('2024-09-12', 'CB', '25', NULL, 3, 3, NULL);

INSERT INTO Contrato_DET (numero_contrato_cab, id_productor_catalogo, vbn, cantidad) VALUES
(1, 1, 1, 500),
(1, 1, 2, 300),
(2, 2, 3, 700),
(2, 2, 4, 400),
(3, 3, 5, 600),
(3, 3, 6, 350),
(4, 3, 7, 450),
(5, 2, 3, 800),
(5, 2, 4, 550),
(6, 3, 5, 200);

INSERT INTO Afiliacion_Sub_Flor (id_casa_subastadora, id_floristeria) VALUES
(1, 1),
(1, 2),
(2, 3),
(2, 4),
(3, 5),
(3, 6);

INSERT INTO Factura_Compra (fecha, monto_total, envio, id_casa_subastadora, id_floristeria) VALUES
('2024-11-01', 0.00, TRUE, 1, 1),
('2024-11-02', 0.00, NULL, 1, 2),
('2024-11-03', 0.00, TRUE, 2, 3),
('2024-11-04', 0.00, NULL, 2, 4),
('2024-11-05', 0.00, TRUE, 3, 5),
('2024-11-06', 0.00, NULL, 3, 6);

INSERT INTO Lote (numero_contrato_cab, vbn, id_productor_catalogo, indice_calidad, precio_inicial, precio_final, cantidad, id_factura_compra) VALUES
(1, 1, 1, 'A', 1200, 1500, 300, 1),
(1, 2, 1, 'B', 1100, 1400, 200, 1),
(2, 3, 2, 'C', 1500, 1700, 400, 2),
(2, 4, 2, 'D', 1300, 1500, 300, 2),
(3, 5, 3, 'E', 1800, 2000, 350, 3),
(3, 6, 3, 'E', 1700, 1900, 250, 3),
(4, 7, 3, 'D', 1600, 1850, 450, 4),
(5, 3, 2, 'C', 1400, 1550, 550, 5),
(5, 4, 2, 'B', 1350, 1500, 300, 5),
(6, 5, 3, 'A', 1600, 1750, 200, 6);


INSERT INTO Factura_Venta_CAB (fecha, monto_total, id_cliente, id_floristeria) VALUES
('2024-11-01', 0.00, 1, 1),
('2024-11-03', 0.00, 2, 1),
('2024-11-05', 0.00, 3, 2),
('2024-11-06', 0.00, 4, 2),
('2024-11-07', 0.00, 5, 3),
('2024-11-08', 0.00, 6, 3),
('2024-11-09', 0.00, 7, 4),
('2024-11-10', 0.00, 8, 4),
('2024-11-11', 0.00, 9, 5),
('2024-11-12', 0.00, 10, 5),
('2024-11-13', 0.00, 11, 6),
('2024-11-14', 0.00, 12, 6);

INSERT INTO Factura_Venta_DET (id_factura_venta_cab, cantidad, valor_calidad, valor_precio, promedio, id_bouquet, cod_catalogo_floristeria_bouquet, id_floristeria_bouquet, cod_catalogo_floristeria, id_floristeria) VALUES
(1, 5, 4, 5, 4.5, 1, 1, 1, NULL, NULL),
(1, 3, 5, 4, 4.5, NULL, NULL, NULL, 2, 1),
(2, 7, 5, 5, 5.0, NULL, NULL, NULL, 3, 2),
(2, 4, 4, 4, 4.0, 4, 4, 2, NULL, NULL),
(3, 6, 5, 4, 4.5, NULL, NULL, NULL, 5, 3),
(4, 8, 4, 5, 4.5, 6, 6, 3, NULL, NULL),
(5, 10, 5, 5, 5.0, NULL, NULL, NULL, 7, 4),
(5, 9, 4, 4, 4.0, 8, 8, 4, NULL, NULL),
(6, 12, 5, 4, 4.5, NULL, NULL, NULL, 9, 5),
(6, 15, 4, 5, 4.5, 10, 10, 5, NULL, NULL),
(7, 8, 5, 4, 4.5, NULL, NULL, NULL, 11, 6),
(8, 10, 5, 5, 5.0, 12, 12, 6, NULL, NULL);

INSERT INTO Telefono (prefijo, cod_area, numero, tipo, id_casa_subastadora, id_productor, id_floristeria, id_cliente) VALUES
(31, 71, 4020950, 'O', 1, NULL, NULL, NULL),
(31, 6, 11133925, 'C', 2, NULL, NULL, NULL),
(31, 88, 7898989, 'O', 3, NULL, NULL, NULL),
(593, 99, 2628178, 'C', NULL, 1, NULL, NULL),
(31, 174, 612121, 'O', NULL, 2, NULL, NULL),
(34, 699, 60302, 'C', NULL, 3, NULL, NULL),
(34, 916, 442213, 'O', NULL, NULL, 1, NULL),
(1, 914, 2347180, 'O', NULL, NULL, 2, NULL),
(353, 87, 4358132, 'C', NULL, NULL, 3, NULL),
(49, 30, 713710, 'O', NULL, NULL, 4, NULL),
(52, 55, 57405092, 'C', NULL, NULL, 5, NULL),
(61, 2, 96107726, 'O', NULL, NULL, 6, NULL),
(593, 2, 987654321, 'C', NULL, NULL, NULL, 1),
(31, 10, 765432123, 'F', NULL, NULL, NULL, 2),
(44, 20, 746554321, 'C', NULL, NULL, NULL, 3),
(1, 305, 754632198, 'F', NULL, NULL, NULL, 4),
(593, 4, 986532198, 'C', NULL, NULL, NULL, 5),
(593, 3, 932456789, 'F', NULL, NULL, NULL, 6),
(34, 91, 712345678, 'C', NULL, NULL, NULL, 7),
(31, 20, 654123987, 'F', NULL, NULL, NULL, 8),
(1, 212, 786543210, 'C', NULL, NULL, NULL, 9),
(593, 7, 912345678, 'F', NULL, NULL, NULL, 10),
(593, 9, 987612345, 'C', NULL, NULL, NULL, 11),
(34, 93, 732145689, 'F', NULL, NULL, NULL, 12),
(593, 6, 987654312, 'C', NULL, NULL, NULL, 13),
(31, 20, 746598321, 'F', NULL, NULL, NULL, 14),
(1, 312, 754698123, 'C', NULL, NULL, NULL, 15),
(34, 95, 786543210, 'F', NULL, NULL, NULL, 16),
(31, 10, 987643210, 'C', NULL, NULL, NULL, 17),
(1, 202, 765423109, 'F', NULL, NULL, NULL, 18),
(593, 5, 986532147, 'C', NULL, NULL, NULL, 19),
(31, 20, 712345987, 'F', NULL, NULL, NULL, 20);


INSERT INTO Pagos_Multas (numero_contrato_cab, fecha_efectiva, monto, concepto) VALUES
(1, '2024-02-15', 750.00, 'Com'),
(1, '2024-03-15', 150.00, 'Mul'),
(2, '2024-04-10', 900.00, 'Com'),
(2, '2024-05-12', 180.00, 'Mul'),
(3, '2024-06-15', 500.00, 'Com'),
(3, '2024-07-20', 100.00, 'Mul'),
(4, '2024-07-15', 1000.00, 'Com'),
(5, '2024-09-15', 850.00, 'Com'),
(5, '2024-10-15', 170.00, 'Mul'),
(6, '2024-10-12', 600.00, 'Com');

INSERT INTO Enlace (id_significado, descripcion, id_flor_corte, codigo_hex) VALUES
(1, 'Pureza', 7, 'ffffff'),
(2, 'Inocencia', 7, 'ffffff'),
(3, 'Perfección', 7, 'ffffff'),
(4, 'Amor', 2, 'ff0000'),
(5, 'Pasión', 2, 'ff0000'),
(6, 'Deseo', 2, 'ff0000'),
(7, 'Amistad', 4, 'ffff00'),
(8, 'Alegría', 4, 'ffff00'),
(9, 'Felicidad', 4, 'ffff00'),
(10, 'Sabiduría', 6, 'ffa500'),
(11, 'Gratitud', 6, 'ffa500'),
(12, 'Reconocimiento', 6, 'ffa500'),
(13, 'Belleza', 11, 'ff0000'),
(14, 'Esperanza', 8, '00ff00'),
(15, 'Adoración', 5, 'ffff00'),
(16, 'Romance', 2, 'ff0000'),
(17, 'Ternura', 2, 'ff0000'),
(18, 'Salud', 5, 'ffff00'),
(19, 'Fidelidad', 5, 'ffff00'),
(20, 'Calma', 9, '4c2882'),
(21, 'Dignidad', 9, '4c2882'),
(22, 'Nobleza', 4, 'ffffff'),
(23, 'Armonía', 8, '00ff00'),
(24, 'Sensualidad', 6, '4c2882'),
(26, 'Graduación', 1, 'ffa500'),
(26, 'Graduación', 3, 'c5388b'),
(27, 'Cumpleaños', 1, 'ffa500'),
(27, 'Cumpleaños', 2, 'c5388b'),
(27, 'Cumpleaños', 4, '4c2882'),
(27, 'Cumpleaños', 5, 'ffff00'),
(27, 'Cumpleaños', 9, 'ff0000'),
(27, 'Cumpleaños', 14, '0000ff'),
(28, 'Boda', 2, 'ffffff'),
(28, 'Boda', 11, 'ffffff'),
(28, 'Boda', 12, 'ffffff'),
(28, 'Boda', 14, 'ffffff'),
(29, 'Funeral', 4, 'ffffff'),
(29, 'Funeral', 7, 'ffffff'),
(29, 'Funeral', 13, 'ffffff'),
(30, 'Velorio', 4, 'ffffff'),
(30, 'Velorio', 7, 'ffffff'),
(31, 'Hospitalización', 5, 'ffff00'),
(31, 'Hospitalización', 6, 'ffffff'),
(31, 'Hospitalización', 8, '0000ff'),
(31, 'Hospitalización', 10, '0000ff'),
(31, 'Hospitalización', 12, 'ffffff'),
(32, 'San Valenín', 2, 'ff0000'),
(32, 'San Valenín', 3, 'ff0000');

INSERT INTO Contacto_Empleado (id_floristeria, nombre, apellido, doc_identidad) VALUES
(1, 'Laura', 'Martínez', '12345678A'),
(1, 'Jorge', 'Ramírez', '87654321B'),
(1, 'Ana', 'López', '19283746C'),
(2, 'Clara', 'Gómez', '23456789C'),
(2, 'Andrés', 'López', '98765432D'),
(2, 'Diego', 'Torres', '29384756E'),
(3, 'Sofía', 'Fernández', '34567890E'),
(3, 'Miguel', 'Hernández', '87654321F'),
(3, 'Valeria', 'Ortiz', '38475629G'),
(4, 'Elena', 'Torres', '45678901G'),
(4, 'Luis', 'Sánchez', '76543210H'),
(4, 'Daniela', 'Cruz', '48596037I'),
(5, 'Camila', 'Morales', '56789012I'),
(5, 'Carlos', 'Pérez', '65432109J'),
(5, 'Roberto', 'Vargas', '57683920K'),
(6, 'Natalia', 'Castillo', '67890123K'),
(6, 'Pedro', 'García', '54321098L'),
(6, 'Sara', 'Medina', '48596012M');

-----------------------------------------------------------------------
--------------- VIEWS -------------------------------------------------
-----------------------------------------------------------------------

CREATE VIEW prod_sub_afiliados AS
SELECT 
    cs.id AS id_casa_subastadora,
    cs.nombre AS nombre_casa_subastadora,
    p.id AS id_productor,
    p.nombre AS nombre_productor,
    cc.numero AS numero_contrato_activo
FROM 
    Casa_Subastadora cs
JOIN 
    Contrato_CAB cc ON cs.id = cc.id_casa_subastadora
JOIN 
    Productor p ON cc.id_productor = p.id
WHERE 
    cc.cancelado IS NULL;


CREATE VIEW flor_sub_afiliados AS
SELECT 
    f.id AS id_floristeria,
    f.nombre AS nombre_floristeria,
    cs.id AS id_casa_subastadora,
    cs.nombre AS nombre_casa_subastadora,
    cc.numero AS numero_contrato_activo
FROM 
    Floristeria f
JOIN 
    Afiliacion_Sub_Flor af ON f.id = af.id_floristeria
JOIN 
    Casa_Subastadora cs ON af.id_casa_subastadora = cs.id
JOIN 
    Contrato_CAB cc ON cs.id = cc.id_casa_subastadora
WHERE 
    cc.cancelado IS NULL;


CREATE VIEW contrato_completos AS
SELECT 
    cc.numero AS numero_contrato,
    cc.fecha AS fecha_contrato,
    cc.clasificacion AS clasificacion_contrato,
    cc.prod_total_pcnt AS porcentaje_total_producido,
    cc.cancelado AS contrato_cancelado,
    cs.id AS id_casa_subastadora,
    cs.nombre AS nombre_casa_subastadora,
    p.id AS id_productor,
    p.nombre AS nombre_productor,
    cd.id_productor_catalogo AS id_productor_catalogo,
    cd.vbn AS vbn,
    cd.cantidad AS cantidad_contratada
FROM 
    Contrato_CAB cc
LEFT JOIN 
    Casa_Subastadora cs ON cc.id_casa_subastadora = cs.id
LEFT JOIN 
    Productor p ON cc.id_productor = p.id
LEFT JOIN 
    Contrato_DET cd ON cc.numero = cd.numero_contrato_cab;


CREATE VIEW facturas_compras AS
SELECT 
    fc.id AS id_factura_compra,
    fc.fecha AS fecha_factura,
    fc.monto_total AS monto_total_factura,
    fc.envio AS envio_incluido,
    cs.id AS id_casa_subastadora,
    cs.nombre AS nombre_casa_subastadora,
    f.id AS id_floristeria,
    f.nombre AS nombre_floristeria,
    l.numero_contrato_cab AS numero_contrato,
    l.vbn AS vbn_lote,
    l.id_productor_catalogo AS id_productor_catalogo,
    l.indice_calidad AS indice_calidad_lote,
    l.precio_inicial AS precio_inicial_lote,
    l.precio_final AS precio_final_lote,
    l.cantidad AS cantidad_comprada
FROM 
    Factura_Compra fc
LEFT JOIN 
    Casa_Subastadora cs ON fc.id_casa_subastadora = cs.id
LEFT JOIN 
    Floristeria f ON fc.id_floristeria = f.id
LEFT JOIN 
    Lote l ON fc.id = l.id_factura_compra;
