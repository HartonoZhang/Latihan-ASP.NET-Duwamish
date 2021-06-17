using BusinessFacade;
using Common.Data;
using Common.Enum;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EateryDuwamish
{
    public partial class Recipe : System.Web.UI.Page
    {
        protected const string DEFAULT_DDL_VALUE = "0";
        protected void Page_Load(object sender, EventArgs e)
        {
            if(Request.QueryString["dishId"] == null)
            {
                Response.Redirect("Dish.aspx");
            }
            if (!IsPostBack)
            {
                ShowNotificationIfExists();
                LoadRecipeTable();
            }
        }

        #region FORM MANAGEMENT
        private void ResetForm()
        {
            hdfRecipeId.Value = String.Empty;
            txtRecipeName.Text = String.Empty;
        }
        private RecipeData GetFormData()
        {
            RecipeData recipe = new RecipeData();
            recipe.RecipeID = String.IsNullOrEmpty(hdfRecipeId.Value) ? 0 : Convert.ToInt32(hdfRecipeId.Value);
            recipe.DishID = Convert.ToInt32(Request.QueryString["dishId"]);
            recipe.RecipeName = txtRecipeName.Text;
            return recipe;
        }
        #endregion

        #region DATA TABLE MANAGEMENT
        private void LoadRecipeTable()
        {
            try
            {
                int dishID = Convert.ToInt32(Request.QueryString["dishId"]);
                List<RecipeData> ListRecipe = new RecipeSystem().GetRecipeList(dishID);
                DishData dish = new DishSystem().GetDishByID(dishID);
                litTableTitle.Text = dish.DishName;
                rptRecipe.DataSource = ListRecipe;
                rptRecipe.DataBind();
            }
            catch (Exception ex)
            {
                notifRecipe.Show($"ERROR LOAD TABLE: {ex.Message}", NotificationType.Danger);
            }
        }
        protected void rptRecipe_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                RecipeData recipe = (RecipeData)e.Item.DataItem;

                LinkButton lbDetailByRecipe = (LinkButton)e.Item.FindControl("lbDetailByRecipe");

                Literal litRecipeName = (Literal)e.Item.FindControl("litRecipeName");

                litRecipeName.Text = recipe.RecipeName;
                lbDetailByRecipe.CommandArgument = recipe.RecipeID.ToString();

                CheckBox chkChoose = (CheckBox)e.Item.FindControl("chkChoose");
                chkChoose.Attributes.Add("data-value", recipe.RecipeID.ToString());
            }
        }
        protected void rptRecipe_ItemCommand(object sender, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DETAIL")
            {
                int recipeID = Convert.ToInt32(e.CommandArgument.ToString());
                Response.Redirect($"~/Ingredient.aspx?recipeId={recipeID}");
            }
        }
        #endregion

        #region BUTTON EVENT MANAGEMENT
        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                RecipeData recipe = GetFormData();
                int dishID = Convert.ToInt32(Request.QueryString["dishId"]);
                int rowAffected = new RecipeSystem().InsertUpdateRecipe(recipe);
                if (rowAffected <= 0)
                    throw new Exception("No Data Recorded");
                Session["save-success"] = 1;
                Response.Redirect($"~/Recipe.aspx?dishId={dishID}");
            }
            catch (Exception ex)
            {
                notifRecipe.Show($"ERROR SAVE DATA: {ex.Message}", NotificationType.Danger);
            }
        }
        protected void btnAdd_Click(object sender, EventArgs e)
        {
            ResetForm();
            litFormType.Text = "TAMBAH";
            pnlFormRecipe.Visible = true;
            txtRecipeName.Focus();
        }
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                string strDeletedIDs = hdfDeletedRecipes.Value;
                int dishID = Convert.ToInt32(Request.QueryString["dishId"]);
                IEnumerable<int> deletedIDs = strDeletedIDs.Split(',').Select(Int32.Parse);
                int rowAffected = new RecipeSystem().DeleteRecipes(deletedIDs);
                if (rowAffected <= 0)
                    throw new Exception("No Data Deleted");
                Session["delete-success"] = 1;
                Response.Redirect($"~/Recipe.aspx?dishId={dishID}");
            }
            catch (Exception ex)
            {
                notifRecipe.Show($"ERROR DELETE DATA: {ex.Message}", NotificationType.Danger);
            }
        }
        #endregion

        #region NOTIFICATION MANAGEMENT
        private void ShowNotificationIfExists()
        {
            if (Session["save-success"] != null)
            {
                notifRecipe.Show("Data sukses disimpan", NotificationType.Success);
                Session.Remove("save-success");
            }
            if (Session["delete-success"] != null)
            {
                notifRecipe.Show("Data sukses dihapus", NotificationType.Success);
                Session.Remove("delete-success");
            }
        }
        #endregion
    }
}