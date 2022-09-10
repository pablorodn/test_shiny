library(shinytest2)

test_that("{shinytest2} recording: test_shiny", {
  app <- AppDriver$new(name = "test_shiny", height = 711, width = 1139)
  app$set_inputs(selection = c("Abraxas grossulariata", "Acer negundo"))
  app$set_inputs(selection = "Abraxas grossulariata")
  app$set_inputs(selection = character(0))
  app$set_inputs(customSwitch1 = TRUE)
  app$set_inputs(customSwitch1 = FALSE)
  app$expect_values()
})
