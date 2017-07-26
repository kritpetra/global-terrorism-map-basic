## Converting from Shiny to Leaflet.js

Convert csv to json:
```r
require(readr)
require(jsonlite)
require(magrittr)

read_csv('./data/terrorismData.csv') %>%
  toJSON() %>%
  write_lines('./data/terrorism_data.json')
```

Try to read in data:
```javascript
// Read in data
var terrorism_data;
$.ajax('./data/terrorism_data.json', {
  success: function(data) {
    terrorism_data = JSON.parse(data);
    console.log(terrorism_data);
  }
});
```
This doesn't work, however. Cannot load local file from the browser and the data is too large anyway.

Let's try to use a SQL database to fetch data instead.
Fortunately, the MySQL Workbench makes it very easy to import data from a .csv file into a SQL table.

Tried for several hours to set everything up in Node.js, also with Babel and webpack so we can use ES6 syntax, but... [Javascript](https://hackernoon.com/how-it-feels-to-learn-javascript-in-2016-d3a717dd577f).

So for now I just put the backend in `server.js`.
