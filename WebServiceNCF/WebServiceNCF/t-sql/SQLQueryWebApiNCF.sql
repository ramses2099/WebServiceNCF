-- =========================================
-- Create table template
-- =========================================

/*--
IF OBJECT_ID('dbo.Estado', 'U') IS NOT NULL
  DROP TABLE dbo.Estado;
GO

CREATE TABLE dbo.Estado
(
	[gkey] [bigint] IDENTITY(1,1) NOT NULL, 
	[descripcion] [varchar](500), 
	[fechasistema] datetime,
	CONSTRAINT PK_Estado PRIMARY KEY (gkey)
)
GO

INSERT INTO dbo.Estado SELECT 'ACTIVO',GETDATE();
INSERT INTO dbo.Estado SELECT 'INACTIVO',GETDATE();

IF OBJECT_ID('dbo.TipoSecuencia', 'U') IS NOT NULL
  DROP TABLE dbo.TipoSecuencia;
GO

CREATE TABLE dbo.TipoSecuencia
(
	[gkey] [bigint] IDENTITY(1,1) NOT NULL, 
	[ncfid] [varchar](2), 
	[descripcion] [varchar](500), 
	[fechasistema] datetime,
	CONSTRAINT PK_TipoSecuencia PRIMARY KEY (gkey)
)
GO


INSERT INTO dbo.TipoSecuencia SELECT '01','Credito Fiscal',GETDATE();
INSERT INTO dbo.TipoSecuencia SELECT '02','Consumidor Final',GETDATE();
INSERT INTO dbo.TipoSecuencia SELECT '04','Nota de credito',GETDATE();
INSERT INTO dbo.TipoSecuencia SELECT '14','Regimenes Especiales de Tributacion',GETDATE();
INSERT INTO dbo.TipoSecuencia SELECT '15','Gubernamentales',GETDATE();


IF OBJECT_ID('dbo.Secuencia', 'U') IS NOT NULL
  DROP TABLE dbo.Secuencia;
GO

CREATE TABLE dbo.Secuencia
(
	[gkey] [bigint] IDENTITY(1,1) NOT NULL,
	[tiposecuencia_gkey] [bigint] NOT NULL,
	[prefijo][varchar](50) NOT NULL,
	[tipo_comprobante][varchar](2) NOT NULL,
	[ultima_secuencia] [varchar](50) NOT NULL,
	[contador] [bigint] NOT NULL,
	[cantidad_digitos] [bigint] NOT NULL,
	[cantidad_secuencia] [bigint] NOT NULL,
	[cantidad_disponible] [bigint] NOT NULL,
	[fecha_vencimiento] datetime NOT NULL,
	[estado_gkey] [bigint] NOT NULL,
	[fechasistema] datetime NOT NULL,
	CONSTRAINT PK_Secuencia PRIMARY KEY (gkey)	
)

ALTER TABLE dbo.Secuencia
ADD CONSTRAINT FK_Secuencia_TipoSecuencia FOREIGN KEY (tiposecuencia_gkey)
	REFERENCES [dbo].[TipoSecuencia] (gkey)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE;

ALTER TABLE dbo.Secuencia
ADD CONSTRAINT FK_Secuencia_Estado FOREIGN KEY (estado_gkey)
	REFERENCES [dbo].[Estado] (gkey)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE;


GO

INSERT INTO dbo.Secuencia SELECT 1,'A','01','A0000000000',0,11,1000,1000,'2019-01-01',1,GETDATE();
INSERT INTO dbo.Secuencia SELECT 2,'B','02','B0000000000',0,11,1000,1000,'2019-01-01',1,GETDATE();
INSERT INTO dbo.Secuencia SELECT 3,'C','04','C0000000000',0,11,1000,1000,'2019-01-01',1,GETDATE();
INSERT INTO dbo.Secuencia SELECT 4,'D','14','D0000000000',0,11,1000,1000,'2019-01-01',1,GETDATE();
INSERT INTO dbo.Secuencia SELECT 5,'E','15','E0000000000',0,11,1000,1000,'2019-01-01',1,GETDATE();


IF OBJECT_ID('[dbo].[Sistema]', 'U') IS NOT NULL
  DROP TABLE [dbo].[Sistema];
GO

CREATE TABLE [dbo].[Sistema]
(
	[gkey] [bigint] IDENTITY(1,1) NOT NULL, 
	[descripcion] [varchar](500), 
	[fechasistema] datetime,
	CONSTRAINT PK_Sistema PRIMARY KEY (gkey)
)
GO

INSERT INTO dbo.Sistema SELECT 'N4 Billing',GETDATE();
INSERT INTO dbo.Sistema SELECT 'AX',GETDATE();



IF OBJECT_ID('dbo.Historico_Secuencia', 'U') IS NOT NULL
  DROP TABLE dbo.Historico_Secuencia;
GO

CREATE TABLE [dbo].[Historico_Secuencia]
(
	[gkey] [bigint] IDENTITY(1,1) NOT NULL,
	[tiposecuencia_gkey] [bigint] NOT NULL,
    [sistema_gkey] [bigint] NOT NULL,
	[numero_factura] [varchar](50) NOT NULL,
	[secuencia] [varchar](50) NOT NULL,
	[cantidad_actual] [bigint] NOT NULL,
	[fecha_vencimiento] datetime NOT NULL,
	[fechasistema] datetime,
	CONSTRAINT PK_Historico_Secuencia PRIMARY KEY (gkey)	
)


ALTER TABLE dbo.Historico_Secuencia
ADD CONSTRAINT FK_Historico_Secuencia_TipoSecuencia FOREIGN KEY (tiposecuencia_gkey)
	REFERENCES [dbo].[TipoSecuencia] (gkey)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE;

ALTER TABLE dbo.Historico_Secuencia
ADD CONSTRAINT FK_Historico_Secuencia_Sistema FOREIGN KEY (sistema_gkey)
	REFERENCES [dbo].[Sistema] (gkey) 
    ON DELETE CASCADE    
    ON UPDATE CASCADE;
	


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[udfGetSecuenciaNCF]
	@tipo_comprobante varchar(2), 
	@sistema bigint,
	@numero_factura varchar(50) 
AS

	--DECLARE @sistema bigint;
	--DECLARE @numero_factura varchar(50); 

	--SET @sistema = 1;
	--SET @numero_factura = 'HIT-120124';
		
	DECLARE @tiposecuencia_gkey bigint;
	DECLARE @prefijo varchar(50);
	DECLARE @tipocomprobante varchar(2);
	DECLARE @ultima_secuencia varchar(50);
	DECLARE @contador bigint;

	DECLARE @cantidad_disponible bigint;	
	DECLARE @fecha_vencimiento datetime;
	DECLARE @cantidad_secuencia bigint;

	DECLARE @NCF varchar(50);

	--SET @tiposecuencia = 3;

	SELECT 
		@tiposecuencia_gkey = [tiposecuencia_gkey],
	    @prefijo = [prefijo],
		@tipocomprobante = [tipo_comprobante],
	    @contador  = ([contador] + 1),
		@cantidad_disponible =([cantidad_disponible] - 1),	
		@fecha_vencimiento = [fecha_vencimiento],
		@cantidad_secuencia = [cantidad_secuencia]
	 FROM dbo.Secuencia WHERE [tipo_comprobante] = @tipo_comprobante and [estado_gkey] = 1;
	
	IF (GETDATE() <= @fecha_vencimiento AND @contador <= @cantidad_secuencia)
	BEGIN 	 		
		SET  @NCF = @prefijo + @tipocomprobante +  RIGHT('00000000' + ltrim(rtrim(@contador)), 10);

		BEGIN TRAN T1
	
			UPDATE  dbo.Secuencia SET
			   ultima_secuencia = @NCF,
			   contador = @contador,
			   cantidad_disponible = @cantidad_disponible
			WHERE [tiposecuencia_gkey] = @tiposecuencia_gkey;

			INSERT INTO [dbo].[Historico_Secuencia]
				 ([tiposecuencia_gkey]
				 ,[sistema_gkey]
				 ,[numero_factura]
				 ,[secuencia]
				 ,[cantidad_actual] 
				 ,[fecha_vencimiento]				 
				 ,[fechasistema])
			VALUES
			   (@tiposecuencia_gkey,
				@sistema,
				@numero_factura,
				@NCF,
				@cantidad_disponible,
				@fecha_vencimiento,
				GETDATE());

		COMMIT TRAN T1;

		SELECT @NCF AS Ncf, @cantidad_disponible AS [Cantidad_Disponible],	
		@fecha_vencimiento AS Fecha_Vencimiento, 'OK' as [mensaje];
	END
	ELSE
	BEGIN
		SELECT NULL AS Ncf, 0 AS [Cantidad_Disponible],	
		@fecha_vencimiento AS Fecha_Vencimiento, 'ERROR' as [mensaje];
	END

-- =============================================
-- Example to execute the stored procedure
-- =============================================

UPDATE dbo.Secuencia SET
cantidad_secuencia = 2,
cantidad_disponible =2,
contador = 0
where tiposecuencia_gkey = 4; 



EXECUTE dbo.udfGetSecuenciaNCF
			@tiposecuencia = 4, 
			@sistema =1,
			@numero_factura='HIT-120125';

GO

 select * from dbo.Secuencia;
 
ALTER VIEW [dbo].[view_historico_secuencia] 
AS
 select 
	H.gkey,
	T.descripcion,
	Si.descripcion as sistema,
	H.numero_factura,
	H.secuencia,
	S.fecha_vencimiento,
	H.cantidad_actual,
	S.cantidad_disponible,
	convert(varchar(10),H.fechasistema,103) as fecha_creacion
  from dbo.Historico_Secuencia H 
  INNER JOIN dbo.Secuencia S ON S.tiposecuencia_gkey = H.tiposecuencia_gkey
  INNER JOIN dbo.TipoSecuencia T ON T.gkey = H.tiposecuencia_gkey
  INNER JOIN dbo.Sistema Si ON Si.gkey = H.sistema_gkey
GO
 

 select * from [dbo].[view_historico_secuencia];

select * from [dbo].[Secuencia]

truncate table [dbo].[Historico_Secuencia]

EXECUTE dbo.udfGetSecuenciaNCF
			@tiposecuencia = 1, 
			@sistema =1,
			@numero_factura='HIT-120127';

UPDATE dbo.Secuencia SET
ultima_secuencia ='C0000000000',
cantidad_secuencia = 1000,
cantidad_disponible =1000,
contador = 0
where tiposecuencia_gkey = 3;



-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'dbo'
     AND SPECIFIC_NAME = N'udfResetSecuenciaNCF' 
)
   DROP PROCEDURE dbo.udfResetSecuenciaNCF;
GO

CREATE PROCEDURE dbo.udfResetSecuenciaNCF

AS

UPDATE dbo.Secuencia SET
ultima_secuencia = prefijo +'0000000000',
cantidad_secuencia = 1000,
cantidad_disponible =1000,
contador = 0;

TRUNCATE TABLE [dbo].[Historico_Secuencia];


IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'dbo'
     AND SPECIFIC_NAME = N'udfGeneraSecuenciaNCF' 
)
   DROP PROCEDURE dbo.udfGeneraSecuenciaNCF;
GO

CREATE PROCEDURE dbo.udfGeneraSecuenciaNCF
 @cantidad INT,
 @tiposecuencia int, 
 @sistema int
AS

DECLARE @contador INT;
DECLARE @numero_factura VARCHAR(20);

SET @Contador = 1;

WHILE (@Contador <= @cantidad)
BEGIN  
    
	SET @numero_factura =('HIT-00000' + CONVERT(varchar,@Contador));

	EXECUTE dbo.udfGetSecuenciaNCF
			@tiposecuencia = @tiposecuencia, 
			@sistema = @sistema,
			@numero_factura= @numero_factura;
	
	SET @Contador = @Contador + 1; 
END  


--*/

-- Select rows from a Table or View 'TableOrViewName' in schema 'SchemaName'
SELECT * FROM dbo.TipoSecuencia;

SELECT * FROM dbo.Secuencia;