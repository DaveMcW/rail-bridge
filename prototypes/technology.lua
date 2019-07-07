-- Recipes are unlocked with Logistics 3
table.insert(data.raw.technology["logistics-3"].effects, {
  type = "unlock-recipe",
  recipe = "rail-bridge",
})
table.insert(data.raw.technology["logistics-3"].effects, {
  type = "unlock-recipe",
  recipe = "rail-bridge-diagonal-left",
})
table.insert(data.raw.technology["logistics-3"].effects, {
  type = "unlock-recipe",
  recipe = "rail-bridge-diagonal-right",
})
