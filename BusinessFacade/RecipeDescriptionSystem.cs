using BusinessRule;
using Common.Data;
using DataAccess;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BusinessFacade
{
    public class RecipeDescriptionSystem
    {
        public RecipeDescriptionData GetRecipeDescriptionByID(int recipeID)
        {
            try
            {
                return new RecipeDescriptionDB().GetRecipeDescriptionByID(recipeID);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public int InsertUpdateRecipeDescription(RecipeDescriptionData recipeDescription)
        {
            try
            {
                return new RecipeDescriptionRule().InsertUpdateRecipeDescription(recipeDescription);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}
