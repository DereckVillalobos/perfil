# Data

The analysis expects a prepared CSV named:

```text
day_preparado.csv
```

Place it in this directory before running the project.

## Expected columns

```text
season
yr
mnth
holiday
weekday
workingday
weathersit
temp
atemp
hum
windspeed
cnt
```

The prepared dataset contains 731 daily observations from the UCI **Bike Sharing** dataset and intentionally excludes `casual` and `registered` to avoid target leakage because those fields directly compose `cnt`.

Source: Fanaee-T, H. (2013). *Bike Sharing*. UCI Machine Learning Repository. DOI: 10.24432/C5W894.

Dataset license: CC BY 4.0.
