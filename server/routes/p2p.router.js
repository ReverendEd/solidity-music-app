const express = require('express');
const pool = require('../modules/pool');
const router = express.Router();
const ExpressPeerServer = require('peer').ExpressPeerServer;

const options = {
    debug: true
}

const PeerServer = require('peer').PeerServer;
const server = PeerServer({port: 9000, path: '/peerjs'});

let peers = []

server.on('connection', (id)=>{
    // verify identity before pushing id
    console.log(id, 'has connected');
    peers.push(id)
});

server.on('disconnect', (id)=>{
    console.log(id, 'has disconnected');
    peers = peers.filter(peerID=>peerID !== id)
});


/**
 * GET route template
 */
router.get('/peers', (req, res) => {
    // verify identity before sending peers
    // make sure no duplicates
    res.send(peers)
});

/**
 * POST route template
 */

module.exports = router;