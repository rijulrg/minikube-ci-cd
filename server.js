'use strict';
const express = require('express');
// Constants
const PORT = 3000;
const HOST = "0.0.0.0";
const app = express();
app.get('/', (req, res) => {
  res.send('Docker and Nodejs');
});
app.listen(PORT, HOST);
console.log(`Running on ${HOST}:${PORT}`);