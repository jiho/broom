# test tidiers for rowwise data frames (that contain individual
# objects as a list column, see ?rowwise_df_tidiers)

context("rowwise tidiers")

library(dplyr)

mods <- mtcars %>%
    group_by(cyl) %>%
    do(mod = lm(mpg ~ wt + qsec, .))

test_that("rowwise tidiers can be applied to sub-models", {
    expect_is(mods, "rowwise_df")
    
    tidied <- mods %>% tidy(mod)
    augmented <- mods %>% augment(mod)
    glanced <- mods %>% glance(mod)
    
    expect_equal(nrow(augmented), nrow(mtcars))
    expect_equal(nrow(glanced), 3)
    expect_true(is.null(augmented$disp))
})

test_that("rowwise tidiers can be given additional arguments", {
    augmented <- mods %>% augment(mod, newdata = head(mtcars, 5))
    expect_equal(nrow(augmented), 3 * 5)
})

test_that("rowwise augment can use a column as the data", {
    mods <- mtcars %>%
        group_by(cyl) %>%
        do(mod = lm(mpg ~ wt + qsec, .), data = (.))
    
    expect_is(mods, "rowwise_df")
    augmented <- mods %>% augment(mod, data = data)
    # order has changed, but original columns should be there
    expect_true(!is.null(augmented$disp))
    expect_equal(sort(mtcars$disp), sort(augmented$disp))
    expect_equal(sort(mtcars$drat), sort(augmented$drat))

    expect_true(!is.null(augmented$.fitted))
    
    # column name doesn't have to be data
    mods <- mtcars %>%
        group_by(cyl) %>%
        do(mod = lm(mpg ~ wt + qsec, .), original = (.))
    augmented <- mods %>% augment(mod, data = original)
    expect_true(!is.null(augmented$disp))
    expect_equal(sort(mtcars$disp), sort(augmented$disp))
})
