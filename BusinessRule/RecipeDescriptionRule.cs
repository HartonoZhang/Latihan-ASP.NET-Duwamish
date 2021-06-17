using Common.Data;
using DataAccess;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SystemFramework;

namespace BusinessRule
{
    public class RecipeDescriptionRule
    {
        public int InsertUpdateRecipeDescription(RecipeDescriptionData recipeDescription)
        {
            SqlConnection SqlConn = null;
            SqlTransaction SqlTran = null;
            try
            {
                SqlConn = new SqlConnection(SystemConfigurations.EateryConnectionString);
                SqlConn.Open();
                SqlTran = SqlConn.BeginTransaction();
                int rowsAffected = new RecipeDescriptionDB().InsertUpdateRecipeDescription(recipeDescription, SqlTran);
                SqlTran.Commit();
                SqlConn.Close();
                return rowsAffected;
            }
            catch (Exception ex)
            {
                SqlTran.Rollback();
                SqlConn.Close();
                throw ex;
            }
        }
    }
}
