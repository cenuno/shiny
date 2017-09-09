# Data for CPS Locator

## Introduction

The data for the CPS Locator comes from the [City of Chicago's Open Data Portal](https://data.cityofchicago.org/#about). It is best described as:

> City of Chicago's open data portal is a lets you find city data, find facts about your neighborhood, lets you create maps and graphs about the city, and lets you freely download the data for your own analysis. Many of these datasets are updated at least once a day, and many of them updated several times a day.

[![City of Chicago's Open Data Portal](https://github.com/cenuno/shiny/raw/master/cps_locator/Images/CityofChicago_DataPortal_HomePage.png)](https://data.cityofchicago.org/)

This folder contains the following:

* [`rawData.R`](https://github.com/cenuno/shiny/blob/master/cps_locator/Data/rawData.R) script: walks the user on how to download a [.CSV](https://en.wikipedia.org/wiki/Comma-separated_values) file of the [Chicago Public Schools - School Profile Information SY1617](https://data.cityofchicago.org/Education/Chicago-Public-Schools-School-Profile-Information-/8i6r-et8s/data) and how to download a [GeoJSON](http://geojson.org/) file of [current community area boundaries in Chicago](https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas-current-/cauq-8yn6).

[![How to Download .CSV Data from City of Chicago Open Data Portal](https://github.com/cenuno/shiny/raw/master/cps_locator/Images/Import_CPS_Data_Into_R.png)](https://data.cityofchicago.org/Education/Chicago-Public-Schools-School-Profile-Information-/8i6r-et8s/data)

[![How to Download GeoJSON data from City of Chicago Open Data Portal](https://github.com/cenuno/shiny/raw/master/cps_locator/Images/Import_CommunityArea_GeoJSON_Into_R.png)](https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas-current-/cauq-8yn6)

* `processedData.R` script: walks the user on cleaning and modifying the data from `rawData.R`.

* `cps_sy1617.RDS file`: the clean data from `processedData.R` is exported as `cps_sy1617` - a [`RDS`](http://stat.ethz.ch/R-manual/R-devel/library/base/html/readRDS.html) file which stores a [R data frame object](http://www.r-tutor.com/r-introduction/data-frame).

## Goal

To make the launch of [CPS Locator](https://cenuno.shinyapps.io/cps_locator/) faster.
