var express = require('express')
var multer  = require('multer')
var upload = multer({ dest: 'uploads/' })
var port = 8080;

var app = express()

app.use(express.static('./client'));

app.post('/profile', upload.single('avatar'), function (req, res, next) {
  // req.file is the `avatar` file
  // req.body will hold the text fields, if there were any
})

app.listen(port, () => console.log(`Example app listening on port ${port}!`));