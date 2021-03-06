﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using WebServiceNCF.Service;

namespace WebServiceNCF
{
    /// <summary>
    /// Summary description for WebServiceNCF
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    //[System.Web.Script.Services.ScriptService]
    public class WebServiceNCF : System.Web.Services.WebService
    {

        [WebMethod]        
        public Service.ResponseMsg GetNCF(DataParam param)
        {

            ResponseMsg response = null;
            try
            {
                if (param.IsReserva != "1")
                {
                    response = DbService.executeTransaction(param.TipoSecuencia, param.Sistema, param.NumeroFactura);
                }
                else
                {
                    response = DbService.executeTransactionReserva(param.TipoSecuencia, param.Sistema, param.NumeroFactura);
                }
            }
            catch (Exception ex)
            {
                new Exception(String.Format("Error en el metodo {0}", ex.Message));
            }

            return response;
        }
        //
        [WebMethod]       
        public Service.ResponseMsgReserva GetReservaNCF(DataParamReserva param)
        {

            ResponseMsgReserva response = null;
            try
            {
                response = DbService.executeTransactionGeneraReserva(param.TipoSecuencia, param.CantidadReserva);
            }
            catch (Exception ex)
            {
                new Exception(String.Format("Error en el metodo {0}", ex.Message));
            }

            return response;
        }
        
    }
}
