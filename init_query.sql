CREATE DATABASE EateryDB

USE [EateryDB]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_General_Split]    Script Date: 20/05/2021 7:23:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_General_Split]
(
	@list VARCHAR(MAX),
	@delimiter VARCHAR(5)
)
RETURNS @retVal TABLE (Id INT IDENTITY(1,1), Value VARCHAR(MAX))
AS
BEGIN
	WHILE (CHARINDEX(@delimiter, @list) > 0)
	BEGIN
		INSERT INTO @retVal (Value)
		SELECT Value = LTRIM(RTRIM(SUBSTRING(@list, 1, CHARINDEX(@delimiter, @list) - 1)))
		SET @list = SUBSTRING(@list, CHARINDEX(@delimiter, @list) + LEN(@delimiter), LEN(@list))
	END
	INSERT INTO @retVal (Value)
	SELECT Value = LTRIM(RTRIM(@list))
	RETURN 
END
GO
/****** Object:  Table [dbo].[msDish]    Script Date: 20/05/2021 7:23:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[msDish](
	[DishID] [int] IDENTITY(1,1) NOT NULL,
	[DishTypeID] [int] NOT NULL,
	[DishName] [varchar](200) NOT NULL,
	[DishPrice] [int] NOT NULL,
	[AuditedActivity] [char](1) NOT NULL,
	[AuditedTime] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DishID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[msDishType]    Script Date: 20/05/2021 7:23:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[msDishType](
	[DishTypeID] [int] IDENTITY(1,1) NOT NULL,
	[DishTypeName] [varchar](100) NOT NULL,
	[AuditedActivity] [char](1) NOT NULL,
	[AuditedTime] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DishTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msDish]  WITH CHECK ADD FOREIGN KEY([DishTypeID])
REFERENCES [dbo].[msDishType] ([DishTypeID])
GO
/****** Object:  StoredProcedure [dbo].[Dish_Delete]    Script Date: 20/05/2021 7:23:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * Created by: Jonathan Ibrahim
 * Date: 10 Mar 2021
 * Purpose: Delete dish
 */
CREATE PROCEDURE [dbo].[Dish_Delete]
	@DishIDs VARCHAR(MAX)
AS
BEGIN
	UPDATE msDish
	SET AuditedActivity = 'D',
		AuditedTime = GETDATE()
	WHERE DishID IN (SELECT value FROM fn_General_Split(@DishIDs, ','))
END
GO
/****** Object:  StoredProcedure [dbo].[Dish_Get]    Script Date: 20/05/2021 7:23:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * Created by: Jonathan Ibrahim
 * Date: 10 Mar 2021
 * Purpose: Get semua dish
 */
CREATE PROCEDURE [dbo].[Dish_Get]
AS
BEGIN
	SELECT 
		DishID,
		DishTypeID,
		DishName, 
		DishPrice 
	FROM msDish WITH(NOLOCK)
	WHERE AuditedActivity <> 'D'
END
GO
/****** Object:  StoredProcedure [dbo].[Dish_GetByID]    Script Date: 20/05/2021 7:23:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * Created by: Jonathan Ibrahim
 * Date: 10 Mar 2021
 * Purpose: Get dish tertentu by Id
 */
CREATE PROCEDURE [dbo].[Dish_GetByID]
	@DishId INT
AS
BEGIN
	SELECT 
		DishID,
		DishTypeID,
		DishName, 
		DishPrice 
	FROM msDish WITH(NOLOCK)
	WHERE DishId = @DishId AND AuditedActivity <> 'D'
END
GO
/****** Object:  StoredProcedure [dbo].[Dish_InsertUpdate]    Script Date: 20/05/2021 7:23:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * Created by: Jonathan Ibrahim
 * Date: 10 Mar 2021
 * Purpose: Insert atau update dish
 */
CREATE PROCEDURE [dbo].[Dish_InsertUpdate]
	@DishID INT OUTPUT,
	@DishTypeID INT,
	@DishName VARCHAR(100),
	@DishPrice INT
AS
BEGIN
	DECLARE @RetVal INT
	IF EXISTS (SELECT 1 FROM msDish WITH(NOLOCK) WHERE DishID = @DishID AND AuditedActivity <> 'D')
	BEGIN
		UPDATE msDish
		SET DishName = @DishName,
			DishTypeID = @DishTypeID,
			DishPrice = @DishPrice,
			AuditedActivity = 'U',
			AuditedTime = GETDATE()
		WHERE DishID = @DishID AND AuditedActivity <> 'D'
		SET @RetVal = @DishID
	END
	ELSE
	BEGIN
		INSERT INTO msDish 
		(DishName, DishTypeID, DishPrice, AuditedActivity, AuditedTime)
		VALUES
		(@DishName, @DishTypeID, @DishPrice, 'I', GETDATE())
		SET @RetVal = SCOPE_IDENTITY()
	END
	SELECT @DishId = @RetVal
END
GO
/****** Object:  StoredProcedure [dbo].[DishType_Get]    Script Date: 20/05/2021 7:23:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * Created by: Jonathan Ibrahim
 * Date: 10 Mar 2021
 * Purpose: Get semua dish type
 */
CREATE PROCEDURE [dbo].[DishType_Get]
AS
BEGIN
	SELECT DishTypeID, DishTypeName FROM msDishType WITH(NOLOCK) 
	WHERE AuditedActivity <> 'D'
END
GO
/****** Object:  StoredProcedure [dbo].[DishType_GetByID]    Script Date: 20/05/2021 7:23:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * Created by: Jonathan Ibrahim
 * Date: 10 Mar 2021
 * Purpose: Get dish type by ID
 */
CREATE PROCEDURE [dbo].[DishType_GetByID]
	@DishTypeID INT
AS
BEGIN
	SELECT DishTypeID, DishTypeName
	FROM msDishType WITH(NOLOCK)
	WHERE DishTypeID = @DishTypeID AND AuditedActivity <> 'D'
END
GO
-- SEEDING msDishType
INSERT INTO msDishType (DishTypeName,AuditedActivity,AuditedTime)
VALUES ('Rumahan','I',GETDATE()), ('Restoran','I',GETDATE()), ('Pinggiran','I',GETDATE())



-- LATIHAN 

/****** Object:  Table [dbo].[msRecipe]    Script Date: 11/06/2021 9:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[msRecipe](
	[RecipeID] [int] IDENTITY(1,1) NOT NULL,
	[DishID] [int] NOT NULL,
	[RecipeName] [varchar](100) NOT NULL,
	[AuditedActivity] [char](1) NOT NULL,
	[AuditedTime] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RecipeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msRecipe]  WITH CHECK ADD FOREIGN KEY([DishID])
REFERENCES [dbo].[msDish] ([DishID])
GO
/****** Object:  Table [dbo].[msIngredient]    Script Date: 13/06/2021 11:03:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[msIngredient](
	[IngredientID] [int] IDENTITY(1,1) NOT NULL,
	[RecipeID] [int] NOT NULL,
	[IngredientName] [varchar](200) NOT NULL,
	[IngredientQuantity] [int] NOT NULL,
	[IngredientUnit] [varchar](100) NOT NULL,
	[AuditedActivity] [char](1) NOT NULL,
	[AuditedTime] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[IngredientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msIngredient]  WITH CHECK ADD FOREIGN KEY([RecipeID])
REFERENCES [dbo].[msRecipe] ([RecipeID])
GO
/****** Object:  Table [dbo].[msRecipeDescription]    Script Date: 13/06/2021 11:13:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[msRecipeDescription](
	[RecipeDescriptionID] [int] IDENTITY(1,1) NOT NULL,
	[RecipeID] [int] NOT NULL,
	[RecipeDescriptionText] [varchar](255) NOT NULL,
	[AuditedActivity] [char](1) NOT NULL,
	[AuditedTime] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RecipeDescriptionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msRecipeDescription]  WITH CHECK ADD FOREIGN KEY([RecipeID])
REFERENCES [dbo].[msRecipe] ([RecipeID])
GO
/****** Object:  StoredProcedure [dbo].[Recipe_GetById]    Script Date: 11/06/2021 9:58:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * Created by: Hartono Zhang
 * Date: 11 Jun 2021
 * Purpose: Get semua recipe by ID
 */
CREATE PROCEDURE [dbo].[Recipe_GetById]
	@DishID INT
AS
BEGIN
	SELECT
		RecipeID,
		DishID,
		RecipeName
	FROM msRecipe WITH(NOLOCK)
	WHERE DishID = @DishID AND AuditedActivity <> 'D'
END
GO
/****** Object:  StoredProcedure [dbo].[Recipe_InsertUpdate]    Script Date: 12/06/2021 7:19:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * Created by: Hartono Zhang
 * Date: 12 Jun 2021
 * Purpose: Insert atau update recipe
 */
CREATE PROCEDURE [dbo].[Recipe_InsertUpdate]
	@RecipeID INT OUTPUT,
	@DishID INT,
	@RecipeName VARCHAR(100)
AS
BEGIN
	DECLARE @RetVal INT
	IF EXISTS (SELECT 1 FROM msRecipe WITH(NOLOCK) WHERE RecipeID = @RecipeID AND AuditedActivity <> 'D')
	BEGIN
		UPDATE msRecipe
		SET RecipeName = @RecipeName,
			DishID = @DishID,
			AuditedActivity = 'U',
			AuditedTime = GETDATE()
		WHERE RecipeID = @RecipeID AND AuditedActivity <> 'D'
		SET @RetVal = @RecipeID
	END
	ELSE
	BEGIN
		INSERT INTO msRecipe 
		(RecipeName, DishID, AuditedActivity, AuditedTime)
		VALUES
		(@RecipeName, @DishID, 'I', GETDATE())
		SET @RetVal = SCOPE_IDENTITY()
	END
	SELECT @RecipeID = @RetVal
END
GO
/****** Object:  StoredProcedure [dbo].[Recipe_Delete]    Script Date: 12/06/2021 7:20:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * Created by: Hartono Zhang
 * Date: 12 Jun 2021
 * Purpose: Delete recipe
 */
CREATE PROCEDURE [dbo].[Recipe_Delete]
	@RecipeIDs VARCHAR(MAX)
AS
BEGIN
	UPDATE msRecipe
	SET AuditedActivity = 'D',
		AuditedTime = GETDATE()
	WHERE RecipeID IN (SELECT value FROM fn_General_Split(@RecipeIDs, ','))
END
GO
/****** Object:  StoredProcedure [dbo].[Recipe_GetOneById]    Script Date: 13/06/2021 11:22:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * Created by: Hartono Zhang
 * Date: 13 Jun 2021
 * Purpose: Get recipe tertentu by ID
 */
CREATE PROCEDURE [dbo].[Recipe_GetOneById]
	@RecipeID INT
AS
BEGIN
	SELECT
		RecipeID,
		DishID,
		RecipeName
	FROM msRecipe WITH(NOLOCK)
	WHERE RecipeID = @RecipeID AND AuditedActivity <> 'D'
END
GO
/****** Object:  StoredProcedure [dbo].[Ingredient_GetById]    Script Date: 13/06/2021 11:24:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * Created by: Hartono Zhang
 * Date: 13 Jun 2021
 * Purpose: Get semua ingredient by ID
 */
CREATE PROCEDURE [dbo].[Ingredient_GetById]
	@RecipeID INT
AS
BEGIN
	SELECT
		IngredientID,
		RecipeID,
		IngredientName,
		IngredientQuantity,
		IngredientUnit
	FROM msIngredient WITH(NOLOCK)
	WHERE RecipeID = @RecipeID AND AuditedActivity <> 'D'
END
GO
/****** Object:  StoredProcedure [dbo].[Ingredient_InsertUpdate]    Script Date: 13/06/2021 11:26:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * Created by: Hartono Zhang
 * Date: 13 Jun 2021
 * Purpose: Insert atau update ingredient
 */
CREATE PROCEDURE [dbo].[Ingredient_InsertUpdate]
	@IngredientID INT OUTPUT,
	@RecipeID INT,
	@IngredientName VARCHAR(200),
	@IngredientQuantity INT,
	@IngredientUnit VARCHAR(100)
AS
BEGIN
	DECLARE @RetVal INT
	IF EXISTS (SELECT 1 FROM msIngredient WITH(NOLOCK) WHERE IngredientID = @IngredientID AND AuditedActivity <> 'D')
	BEGIN
		UPDATE msIngredient
		SET IngredientName = @IngredientName,
			RecipeID = @RecipeID,
			IngredientQuantity = @IngredientQuantity,
			IngredientUnit = @IngredientUnit,
			AuditedActivity = 'U',
			AuditedTime = GETDATE()
		WHERE IngredientID = @IngredientID AND AuditedActivity <> 'D'
		SET @RetVal = @IngredientID
	END
	ELSE
	BEGIN
		INSERT INTO msIngredient 
		(IngredientName, RecipeID, IngredientQuantity, IngredientUnit, AuditedActivity, AuditedTime)
		VALUES
		(@IngredientName, @RecipeID, @IngredientQuantity, @IngredientUnit, 'I', GETDATE())
		SET @RetVal = SCOPE_IDENTITY()
	END
	SELECT @IngredientID = @RetVal
END
GO
/****** Object:  StoredProcedure [dbo].[Ingredient_Delete]    Script Date: 13/06/2021 11:32:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * Created by: Hartono Zhang
 * Date: 13 Jun 2021
 * Purpose: Delete ingredient
 */
CREATE PROCEDURE [dbo].[Ingredient_Delete]
	@IngredientIDs VARCHAR(MAX)
AS
BEGIN
	UPDATE msIngredient
	SET AuditedActivity = 'D',
		AuditedTime = GETDATE()
	WHERE IngredientID IN (SELECT value FROM fn_General_Split(@IngredientIDs, ','))
END
GO
/****** Object:  StoredProcedure [dbo].[Ingredient_GetOneByID]    Script Date: 13/06/2021 11:24:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * Created by: Hartono Zhang
 * Date: 13 Jun 2021
 * Purpose: Get ingredient tertentu by Id
 */
CREATE PROCEDURE [dbo].[Ingredient_GetOneByID]
	@IngredientID INT
AS
BEGIN
	SELECT 
		IngredientID,
		RecipeID,
		IngredientName, 
		IngredientQuantity,
		IngredientUnit
	FROM msIngredient WITH(NOLOCK)
	WHERE IngredientID = @IngredientID AND AuditedActivity <> 'D'
END
GO
/****** Object:  StoredProcedure [dbo].[RecipeDescription_GetByID]    Script Date: 13/06/2021 11:38:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * Created by: Hartono Zhang
 * Date: 13 Jun 2021
 * Purpose: Get recipe description tertentu by Id
 */
CREATE PROCEDURE [dbo].[RecipeDescription_GetByID]
	@RecipeID INT
AS
BEGIN
	SELECT 
		RecipeDescriptionID,
		RecipeID,
		RecipeDescriptionText
	FROM msRecipeDescription WITH(NOLOCK)
	WHERE RecipeID = @RecipeID AND AuditedActivity <> 'D'
END
GO
/****** Object:  StoredProcedure [dbo].[RecipeDescription_InsertUpdate]    Script Date: 14/06/2021 10:35:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * Created by: Hartono Zhang
 * Date: 14 Jun 2021
 * Purpose: Insert atau update recipe description
 */
CREATE PROCEDURE [dbo].[RecipeDescription_InsertUpdate]
	@RecipeDescriptionID INT OUTPUT,
	@RecipeID INT,
	@RecipeDescriptionText VARCHAR(255)
AS
BEGIN
	DECLARE @RetVal INT
	IF EXISTS (SELECT 1 FROM msRecipeDescription WITH(NOLOCK) WHERE RecipeDescriptionID = @RecipeDescriptionID AND AuditedActivity <> 'D')
	BEGIN
		UPDATE msRecipeDescription
		SET RecipeDescriptionText = @RecipeDescriptionText,
			RecipeID = @RecipeID,
			AuditedActivity = 'U',
			AuditedTime = GETDATE()
		WHERE RecipeDescriptionID = @RecipeDescriptionID AND AuditedActivity <> 'D'
		SET @RetVal = @RecipeDescriptionID
	END
	ELSE
	BEGIN
		INSERT INTO msRecipeDescription 
		(RecipeDescriptionText, RecipeID, AuditedActivity, AuditedTime)
		VALUES
		(@RecipeDescriptionText, @RecipeID, 'I', GETDATE())
		SET @RetVal = SCOPE_IDENTITY()
	END
	SELECT @RecipeDescriptionID = @RetVal
END
GO

SELECT * FROM msDish
SELECT * FROM msDishType
SELECT * FROM msRecipe
SELECT * FROM msIngredient
SELECT * FROM msRecipeDescription