using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Data.SqlClient;

namespace WebServiceNCF.Service
{
    public class DbService
    {

        //
        private static string ConnectionString { get { return System.Web.Configuration.WebConfigurationManager.ConnectionStrings["NCFConnectionString"].ToString(); } }

        /// <summary>
        /// 
        /// </summary>
        public static ResponseMsg executeTransaction(String TipoSecuencia, String Sistema, String NumeroFactura)
        {
            ResponseMsg rs = null;

            try
            {

                using (SqlConnection connetion = new SqlConnection(ConnectionString))
                {

                    if (connetion.State == ConnectionState.Closed)
                    {
                        connetion.Open();
                    }

                    using (SqlCommand _DbCommand = new SqlCommand())
                    {
                        _DbCommand.Connection = connetion;

                        _DbCommand.CommandType = CommandType.StoredProcedure;

                        _DbCommand.CommandText = "dbo.udfGetSecuenciaNCF";

                        _DbCommand.Parameters.Add(new SqlParameter() { ParameterName = "@tipo_comprobante", SqlDbType = SqlDbType.VarChar, Value = TipoSecuencia });

                        _DbCommand.Parameters.Add(new SqlParameter() { ParameterName = "@sistema", SqlDbType = SqlDbType.VarChar, Value = Sistema });

                        _DbCommand.Parameters.Add(new SqlParameter() { ParameterName = "@numero_factura", SqlDbType = SqlDbType.VarChar, Value = NumeroFactura });

                        using (SqlDataReader dr = _DbCommand.ExecuteReader())
                        {

                            if (dr.HasRows)
                            {
                                rs = new ResponseMsg();

                                while (dr.Read())
                                {

                                    if (dr["Ncf"] != DBNull.Value)
                                    {
                                        rs.NCF = dr["Ncf"].ToString();
                                    }
                                    //
                                    if (dr["Cantidad_Disponible"] != DBNull.Value)
                                    {
                                        rs.Cantidad_Disponible = dr["Cantidad_Disponible"].ToString();
                                    }
                                    //
                                    if (dr["Fecha_Vencimiento"] != DBNull.Value)
                                    {
                                        rs.Fecha_Vencimiento = dr["Fecha_Vencimiento"].ToString();
                                    }
                                    //
                                    if (dr["Mensaje"] != DBNull.Value)
                                    {
                                        rs.Mensaje = dr["Mensaje"].ToString();
                                    }
                                    //
                                }

                            }
                        }
                    }

                }


            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }

            return rs;
        }


    }
}