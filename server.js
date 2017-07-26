var mysql = require('mysql');
var express = require('express');
var app = express();
console.log("current user is", process.env.SQL_DB_USER); // XXX
console.log("current password is", process.env.SQL_DB_PASSWORD); // XXX
var connection = mysql.createConnection({
  host: 'localhost',
  user: process.env.SQL_DB_USER,
  password: process.env.SQL_DB_PASSWORD,
  database: 'gtd'
});

app.get('/', function (req, res) {
  res.send('Hello World!')
})

app.get('/coordinates', function (req, res) {
  connection.query("SELECT latitude, longitude FROM incident LIMIT 10", function (err, result) {
    if (err) throw err;
    res.send(result.map(e => [e.latitude, e.longitude]));
  });
});

app.listen(3000, function () {
  console.log('Example app listening on port 3000!')
})
