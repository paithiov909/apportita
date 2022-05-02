img <- file.path(
  getwd(),
  "man",
  "figures",
  "silicon.png"
)

hexSticker::sticker(
  img,
  s_x = 1,
  s_width = .5,
  s_height = .5,
  p_size = 20,
  package = "apportita",
  p_color = "#fc6baf",
  h_size = 3,
  h_fill = "#84bcfc",
  h_color = "#84fcc4",
  filename = "man/figures/logo-origin.png"
)

usethis::use_logo("man/figures/logo-origin.png")
pkgdown::build_favicons(overwrite = TRUE)
