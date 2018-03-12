SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[udfGetSecuenciaNCF]
	@tipo_comprobante varchar(2), 
	@sistema bigint,
	@numero_factura varchar(50) 
AS
--yrdyr
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

