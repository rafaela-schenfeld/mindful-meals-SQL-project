-- Create schema script for Mindful Meals Database
-- This database schema is designed to manage user data, ingredients, recipes, and meal planning functionality for the Mindful Meals app. Each table is built with specific purposes related to storing and retrieving meal planning data.

-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS mindful_meals;
USE mindful_meals;

-- Users table
-- This table stores basic user information such as usernames, email addresses, and hashed passwords. It also tracks the account creation date for auditing purposes.
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each user
    username VARCHAR(100) NOT NULL, -- Username of the user
    email VARCHAR(100) NOT NULL UNIQUE, -- User's email, must be unique
    password_hash VARCHAR(100) NOT NULL, -- Hashed password for security
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp of when the user registered
);

-- Ingredients table
-- This table stores the details of each ingredient that can be used in recipes or meal planning, such as name, category, storage type, and estimated expiration time.
CREATE TABLE ingredients (
    ingredient_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each ingredient
    name VARCHAR(100) NOT NULL, -- Name of the ingredient
    category VARCHAR(50), -- Category (e.g., vegetable, fruit, dairy)
    unit VARCHAR(50), -- Unit of measurement (e.g., grams, liters)
    expiration_approx INT, -- Approximate expiration time in days
    main_food TINYINT(1) DEFAULT 1, -- Whether the ingredient is considered a main food item (binary flag)
    storage_type VARCHAR(50) NOT NULL, -- Storage type (e.g., fridge, pantry)
    emoji VARCHAR(10) -- Emoji representation of the ingredient for visual purposes
);

-- User Ingredients table
-- This table links users to the ingredients they have, tracking quantities, expiration dates, and how much of each ingredient remains.
CREATE TABLE user_ingredients (
    user_ingredient_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for the user-ingredient relationship
    user_id INT NOT NULL, -- The user who owns the ingredient
    ingredient_id INT NOT NULL, -- The ingredient in question
    quantity FLOAT NOT NULL, -- Total quantity of the ingredient the user owns
    remaining_quantity FLOAT NOT NULL, -- Quantity remaining after usage
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- When the ingredient was added to the user's pantry
    expiration_date TIMESTAMP, -- Expiration date of the ingredient
    FOREIGN KEY (user_id) REFERENCES users(user_id), -- Links the ingredient to a specific user
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id) -- Links to the corresponding ingredient in the Ingredients table
);

-- Recipes table
-- Stores data related to recipes, including titles, descriptions, preparation and cooking time, and difficulty levels.
CREATE TABLE recipes (
    recipe_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each recipe
    title VARCHAR(100) NOT NULL, -- Title of the recipe
    description TEXT NOT NULL, -- Full description or instructions for the recipe
    cuisine VARCHAR(50), -- Type of cuisine (e.g., Italian, Chinese)
    prep_time INT, -- Time in minutes to prepare the recipe
    cook_time INT, -- Time in minutes to cook the recipe
    difficulty VARCHAR(50), -- Difficulty level (e.g., easy, medium, hard)
);

-- Recipe Ingredients table
-- Associates recipes with the ingredients used, including the quantity needed for the recipe.
CREATE TABLE recipe_ingredients (
    recipe_id INT NOT NULL, -- The recipe to which the ingredient belongs
    ingredient_id INT NOT NULL, -- The ingredient used in the recipe
    quantity FLOAT, -- Quantity of the ingredient needed for the recipe
    PRIMARY KEY (recipe_id, ingredient_id), -- Composite key to ensure that each ingredient is linked to a single recipe only once
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id), -- Links the ingredient to a specific recipe
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id) -- Links the ingredient to the Ingredients table
);

-- Recipe Instructions table
-- Stores instructions for each recipe, ordered by step number.
CREATE TABLE recipe_instruction (
    recipe_id INT NOT NULL, -- The recipe to which the instruction belongs
    step_number INT NOT NULL, -- The step number of the instruction
    instruction TEXT, -- The text of the instruction
    PRIMARY KEY (recipe_id, step_number), -- Composite primary key to ensure unique steps for each recipe
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id) -- Links the instruction to the corresponding recipe
);

-- Ingredients Usage table
-- Tracks the usage of ingredients by the user, including the quantity used and the remaining amount after each use.
CREATE TABLE ingredients_usage (
    usage_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each usage record
    user_ingredient_id INT NOT NULL, -- The user-ingredient relationship being tracked
    used_quantity FLOAT NOT NULL, -- Quantity of the ingredient used in this instance
    remaining_quantity_after_use FLOAT NOT NULL, -- Remaining quantity after the usage
    usage_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of when the usage occurred
    FOREIGN KEY (user_ingredient_id) REFERENCES user_ingredients(user_ingredient_id) -- Links to the specific user ingredient
);

-- Restriction table
-- Stores dietary restrictions that can be applied to recipes (e.g., Vegan, Gluten-Free).
CREATE TABLE restriction (
    tag_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each restriction
    name VARCHAR(50) NOT NULL -- Name of the restriction (e.g., Vegan, Gluten-Free)
);

-- Recipe Restriction table
-- Associates dietary restrictions with recipes.
CREATE TABLE recipe_restriction (
    recipe_id INT NOT NULL, -- The recipe to which the restriction applies
    tag_id INT NOT NULL, -- The restriction (e.g., Vegan, Gluten-Free)
    PRIMARY KEY (recipe_id, tag_id), -- Composite primary key to ensure that each recipe has a unique set of restrictions
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id), -- Links the restriction to the corresponding recipe
    FOREIGN KEY (tag_id) REFERENCES restriction(tag_id) -- Links the restriction to the restriction tag
);

-- Meal Plan table
-- Stores information about user-generated meal plans, including the number of servings and when the plan was created.
CREATE TABLE meal_plan (
    user_id INT NOT NULL, -- The user who created the meal plan
    created_at TIMESTAMP NOT NULL, -- Timestamp when the meal plan was created
    servings INT NOT NULL, -- Number of servings planned
    PRIMARY KEY (user_id, created_at), -- Composite primary key of user and timestamp
    FOREIGN KEY (user_id) REFERENCES users(user_id) -- Links to the user who owns the meal plan
);

-- Meal Plan Recipes table
-- Links meal plans to recipes, tracking whether the recipe has been cooked and when it was cooked.
CREATE TABLE meal_plan_recipes (
    user_id INT NOT NULL, -- The user who created the meal plan
    created_at TIMESTAMP NOT NULL, -- Timestamp when the meal plan was created
    recipe_id INT NOT NULL, -- The recipe included in the meal plan
    cooked TINYINT(1) NOT NULL, -- Whether the recipe has been cooked (binary flag)
    cooked_on TIMESTAMP, -- Timestamp of when the recipe was cooked
    PRIMARY KEY (user_id, created_at, recipe_id), -- Composite primary key to uniquely identify a meal plan and its recipes
    FOREIGN KEY (user_id, created_at) REFERENCES meal_plan(user_id, created_at), -- Links to the meal plan
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id) -- Links to the recipe
);