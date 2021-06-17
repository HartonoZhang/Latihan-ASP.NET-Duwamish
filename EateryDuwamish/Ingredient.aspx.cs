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
    public partial class Ingredient : System.Web.UI.Page
    {
        protected const string DEFAULT_DDL_VALUE = "0";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["recipeId"] == null)
            {
                Response.Redirect("Dish.aspx");
            }
            if (!IsPostBack)
            {
                ShowNotificationIfExists();
                LoadIngredientTable();
                LoadRecipeDescription();
            }
        }
        #region FORM MANAGEMENT
        private void FillForm(IngredientData ingredient)
        {
            hdfIngredientId.Value = ingredient.IngredientID.ToString();
            hdfRecipeId.Value = ingredient.RecipeID.ToString();
            txtIngredientName.Text = ingredient.IngredientName;
            txtIngredientQuantity.Text = ingredient.IngredientQuantity.ToString();
            txtIngredientUnit.Text = ingredient.IngredientUnit;
        }
        private void ResetForm()
        {
            hdfIngredientId.Value = String.Empty;
            hdfRecipeId.Value = String.Empty;
            txtIngredientName.Text = String.Empty;
            txtIngredientQuantity.Text = String.Empty;
            txtIngredientUnit.Text = String.Empty;
        }
        private IngredientData GetFormData()
        {
            IngredientData ingredient = new IngredientData();
            ingredient.IngredientID = String.IsNullOrEmpty(hdfIngredientId.Value) ? 0 : Convert.ToInt32(hdfIngredientId.Value);
            ingredient.RecipeID = Convert.ToInt32(Request.QueryString["recipeId"]);
            ingredient.IngredientName = txtIngredientName.Text;
            ingredient.IngredientQuantity = Convert.ToInt32(txtIngredientQuantity.Text);
            ingredient.IngredientUnit = txtIngredientUnit.Text;
            return ingredient;
        }
        private RecipeDescriptionData GetRecipeDescriptionData()
        {
            RecipeDescriptionData recipeDescription = new RecipeDescriptionData();
            recipeDescription.RecipeDescriptionID = String.IsNullOrEmpty(hdfRecipeDescriptionId.Value) ? 0 : Convert.ToInt32(hdfRecipeDescriptionId.Value);
            recipeDescription.RecipeID = Convert.ToInt32(Request.QueryString["recipeId"]);
            recipeDescription.RecipeDescriptionText = txtRecipeDescriptionText.Text;
            return recipeDescription;
        }
        #endregion

        #region DATA TABLE MANAGEMENT
        private void LoadRecipeDescription()
        {

            int recipeID = Convert.ToInt32(Request.QueryString["recipeId"]);
            RecipeDescriptionData recipeDescription = new RecipeDescriptionSystem().GetRecipeDescriptionByID(recipeID);
            txtRecipeDescriptionText.TextMode = TextBoxMode.MultiLine;
            txtRecipeDescriptionText.Rows = 8;
            if (recipeDescription == null)
            {
                return;
            }
            hdfRecipeDescriptionId.Value = recipeDescription.RecipeDescriptionID.ToString();
            hdfRecipeId.Value = recipeDescription.RecipeID.ToString();
            txtRecipeDescriptionText.Text = recipeDescription.RecipeDescriptionText;
        }
        private void LoadIngredientTable()
        {
            try
            {
                int recipeID = Convert.ToInt32(Request.QueryString["recipeId"]);
                List<IngredientData> ListIngredient = new IngredientSystem().GetIngredientList(recipeID);
                RecipeData recipe = new RecipeSystem().GetRecipeByID(recipeID);
                litPageTitle.Text = recipe.RecipeName;
                rptIngredient.DataSource = ListIngredient;
                rptIngredient.DataBind();
            }
            catch (Exception ex)
            {
                notifIngredient.Show($"ERROR LOAD TABLE: {ex.Message}", NotificationType.Danger);
            }
        }
        protected void rptIngredient_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                IngredientData ingredient = (IngredientData)e.Item.DataItem;

                LinkButton lbEditByIngredient = (LinkButton)e.Item.FindControl("lbEditByIngredient");

                Literal litIngredientName = (Literal)e.Item.FindControl("litIngredientName");
                HiddenField hdfRecipeId = (HiddenField)e.Item.FindControl("hdfRecipeId");
                Literal litIngredientQuantity = (Literal)e.Item.FindControl("litIngredientQuantity");
                Literal litIngredientUnit = (Literal)e.Item.FindControl("litIngredientUnit");

                litIngredientName.Text = ingredient.IngredientName;

                lbEditByIngredient.CommandArgument = ingredient.IngredientID.ToString();

                hdfRecipeId.Value = ingredient.RecipeID.ToString();
                litIngredientQuantity.Text = ingredient.IngredientQuantity.ToString();
                litIngredientUnit.Text = ingredient.IngredientUnit;

                CheckBox chkChoose = (CheckBox)e.Item.FindControl("chkChoose");
                chkChoose.Attributes.Add("data-value", ingredient.IngredientID.ToString());
            }
        }
        protected void rptIngredient_ItemCommand(object sender, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "EDIT")
            {
                Literal litIngredientName = (Literal)e.Item.FindControl("litIngredientName");
                HiddenField hdfRecipeId = (HiddenField)e.Item.FindControl("hdfRecipeId");
                Literal litIngredientQuantity = (Literal)e.Item.FindControl("litIngredientQuantity");
                Literal litIngredientUnit = (Literal)e.Item.FindControl("litIngredientUnit");

                int ingredientID = Convert.ToInt32(e.CommandArgument.ToString());
                IngredientData ingredient = new IngredientSystem().GetIngredientByID(ingredientID);
                FillForm(new IngredientData
                {
                    IngredientID = ingredient.IngredientID,
                    RecipeID = ingredient.RecipeID,
                    IngredientName = ingredient.IngredientName,
                    IngredientQuantity = ingredient.IngredientQuantity,
                    IngredientUnit = ingredient.IngredientUnit
                });
                litFormType.Text = $"UBAH: {litIngredientName.Text}";
                pnlFormIngredient.Visible = true;
                txtIngredientName.Focus();
            }
        }
        #endregion

        #region BUTTON EVENT MANAGEMENT
        protected void btnSaveRecipeDescription_Click(object sender, EventArgs e)
        {
            try
            {
                RecipeDescriptionData recipeDescription = GetRecipeDescriptionData();
                int recipeID = Convert.ToInt32(Request.QueryString["recipeId"]);
                int rowAffected = new RecipeDescriptionSystem().InsertUpdateRecipeDescription(recipeDescription);
                if (rowAffected <= 0)
                    throw new Exception("No Data Recorded");
                Session["save-success"] = 1;
                Response.Redirect($"~/Ingredient.aspx?recipeId={recipeID}");
            }
            catch (Exception ex)
            {
                notifIngredient.Show($"ERROR SAVE DATA: {ex.Message}", NotificationType.Danger);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                IngredientData ingredient = GetFormData();
                int recipeID = Convert.ToInt32(Request.QueryString["recipeId"]);
                int rowAffected = new IngredientSystem().InsertUpdateIngredient(ingredient);
                if (rowAffected <= 0)
                    throw new Exception("No Data Recorded");
                Session["save-success"] = 1;
                Response.Redirect($"~/Ingredient.aspx?recipeId={recipeID}");
            }
            catch (Exception ex)
            {
                notifIngredient.Show($"ERROR SAVE DATA: {ex.Message}", NotificationType.Danger);
            }
        }
        protected void btnAdd_Click(object sender, EventArgs e)
        {
            ResetForm();
            litFormType.Text = "TAMBAH";
            pnlFormIngredient.Visible = true;
            txtIngredientName.Focus();
        }
        protected void btnEditRecipeDescription_Click(object sender, EventArgs e)
        {
            txtRecipeDescriptionText.ReadOnly = false;
        }
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                string strDeletedIDs = hdfDeletedIngredients.Value;
                int recipeID = Convert.ToInt32(Request.QueryString["recipeId"]);
                IEnumerable<int> deletedIDs = strDeletedIDs.Split(',').Select(Int32.Parse);
                int rowAffected = new IngredientSystem().DeleteIngredients(deletedIDs);
                if (rowAffected <= 0)
                    throw new Exception("No Data Deleted");
                Session["delete-success"] = 1;
                Response.Redirect($"~/Ingredient.aspx?recipeId={recipeID}");
            }
            catch (Exception ex)
            {
                notifIngredient.Show($"ERROR DELETE DATA: {ex.Message}", NotificationType.Danger);
            }
        }
        #endregion

        #region NOTIFICATION MANAGEMENT
        private void ShowNotificationIfExists()
        {
            if (Session["save-success"] != null)
            {
                notifIngredient.Show("Data sukses disimpan", NotificationType.Success);
                Session.Remove("save-success");
            }
            if (Session["delete-success"] != null)
            {
                notifIngredient.Show("Data sukses dihapus", NotificationType.Success);
                Session.Remove("delete-success");
            }
        }
        #endregion
    }
}