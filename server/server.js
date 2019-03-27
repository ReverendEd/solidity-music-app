
const express = require('express');
require('dotenv').config();

const app = express();
const bodyParser = require('body-parser');


// Route includes

const p2pRouter = require('./routes/p2p.router')

// Body parser middleware
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Passport Session Configuration //

// start up passport sessions

/* Routes */

app.use('/api/p2p', p2pRouter)


// Serve static files
app.use(express.static('build'));

// App Set //
const PORT = process.env.PORT || 5000;

/** Listen * */
app.listen(PORT, () => {
  console.log(`Listening on port: ${PORT}`);
});
