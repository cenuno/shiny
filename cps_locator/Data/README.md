# Data for CPS Locator Shiny App

## Overview

This folder contains the following:

* `rawData.R` script: walks the user on how to download a .CSV file of the [Chicago Public Schools - School Profile Information SY1617](https://data.cityofchicago.org/Education/Chicago-Public-Schools-School-Profile-Information-/8i6r-et8s/data).

* `processedData.R` script: walks the user on cleaning and modifying the data from `rawData.R`.

* cps_sy1617.RDS file: the clean data from `processedData.R` is exported as `cps_sy1617` - a [`RDS`](http://stat.ethz.ch/R-manual/R-devel/library/base/html/readRDS.html) file which stores a [R data frame object](http://www.r-tutor.com/r-introduction/data-frame).

## Goal

To make the launch of [CPS Locator](https://cenuno.shinyapps.io/cps_locator/) faster.
