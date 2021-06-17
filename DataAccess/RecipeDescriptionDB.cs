using Common.Data;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SystemFramework;

namespace DataAccess
{
    public class RecipeDescriptionDB
    {
        public RecipeDescriptionData GetRecipeDescriptionByID(int recipeID)
        {
            try
            {
                string SpName = "dbo.RecipeDescription_GetByID";
                RecipeDescriptionData recipeDescription = null;
                using (SqlConnection SqlConn = new SqlConnection())
                {
                    SqlConn.ConnectionString = SystemConfigurations.EateryConnectionString;
                    SqlConn.Open();
                    SqlCommand SqlCmd = new SqlCommand(SpName, SqlConn);
                    SqlCmd.CommandType = CommandType.StoredProcedure;
                    SqlCmd.Parameters.Add(new SqlParameter("@RecipeID", recipeID));
                    using (SqlDataReader Reader = SqlCmd.ExecuteReader())
                    {
                        if (Reader.HasRows)
                        {
                            Reader.Read();
                            recipeDescription = new RecipeDescriptionData();
                            recipeDescription.RecipeDescriptionID = Convert.ToInt32(Reader["RecipeDescriptionID"]);
                            recipeDescription.RecipeID = Convert.ToInt32(Reader["RecipeID"]);
                            recipeDescription.RecipeDescriptionText = Convert.ToString(Reader["RecipeDescriptionText"]);
                        }
                    }
                    SqlConn.Close();
                }
                return recipeDescription;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public int InsertUpdateRecipeDescription(RecipeDescriptionData recipeDescription, SqlTransaction SqlTran)
        {
            try
            {
                string SpName = "dbo.RecipeDescription_InsertUpdate";
                SqlCommand SqlCmd = new SqlCommand(SpName, SqlTran.Connection, SqlTran);
                SqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter RecipeDescriptionId = new SqlParameter("@RecipeDescriptionID", recipeDescription.RecipeDescriptionID);
                RecipeDescriptionId.Direction = ParameterDirection.InputOutput;
                SqlCmd.Parameters.Add(RecipeDescriptionId);

                SqlCmd.Parameters.Add(new SqlParameter("@RecipeID", recipeDescription.RecipeID));
                SqlCmd.Parameters.Add(new SqlParameter("@RecipeDescriptionText", recipeDescription.RecipeDescriptionText));
                return SqlCmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}
