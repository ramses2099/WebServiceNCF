using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebServiceNCF.Service
{
    public class ResponseMsg
    {
        public String NCF { get; set; }
        public String Cantidad_Disponible { get; set; }
        public String Fecha_Vencimiento { get; set; }
        public String Mensaje { get; set; }

    }
}