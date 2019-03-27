const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3'); //full class
const web3 = new Web3(ganache.provider());

const compiledProjectFactory = require('../ethereum/build/ProjectFactory.json');

let accounts;
let factory;

beforeEach(async () => {
    accounts = await web3.eth.getAccounts();

    factory = await new web3.eth.Contract(JSON.parse(compiledProjectFactory.interface))
        .deploy({ data: compiledProjectFactory.bytecode })
        .send({ from: accounts[0], gas: '4000000' })

    // await factory.methods.createCampaign('100').send({
    //     from: accounts[0],
    //     gas: '1000000'
    // });

    // [campaignAddress] = await factory.methods.getDeployedCampaigns().call();

    // campaign = await new web3.eth.Contract(
    //     JSON.parse(compiledCampaign.interface),
    //     campaignAddress
    // );
})

describe('Factory', () => {
    it('deploys a factory', () => {
        assert.ok(factory.options.address);
    });

    it('registers and returns a user', async () => {
        await factory.methods.registerUser(web3.utils.fromAscii('Reverend Ed'))
        .send({
            from: accounts[0],
            gas: '400000'
        })
        let user = await factory.methods.findUser(accounts[0]).call();
        user = web3.utils.toAscii(user)   
        assert.equal(user.substring(0, 11), 'Reverend Ed')
    })

    it('does not overwrite an existing user', async ()=>{
        await factory.methods.registerUser(web3.utils.fromAscii('Reverend Ed'))
        .send({
            from: accounts[0],
            gas: '400000'
        })

        await factory.methods.registerUser(web3.utils.fromAscii('chuck loggi'))
        .send({
            from: accounts[0],
            gas: '400000'
        })
        let user = await factory.methods.findUser(accounts[0]).call();
        user = web3.utils.toAscii(user)
        assert.notEqual(user.substring(0,11), 'chuck loggi')
        assert.equal(user.substring(0,11), 'Reverend Ed')
    })

    it('returns nothing for nonexistent user', async ()=>{
        let user = await factory.methods.findUser(accounts[0]).call();   
        assert(user[0], 0)
    })

    it('creates a project and gets it from getUserProject', async ()=>{
        await factory.methods.registerUser(web3.utils.fromAscii('Reverend Ed'))
        .send({
            from: accounts[0],
            gas: '400000'
        })

        const r = web3.utils.fromAscii
        await factory.methods.createProject(r('project'), r('description'), r('tags'), 3, r('starter file'), 0, [])
        .send({
            from: accounts[0],
            gas: '4000000',
            value: web3.utils.fromWei('10000000000000000000', 'ether')
        })
        const projects = await factory.methods.getDeployedProjects().call()
        assert.ok(projects[0])

        // fix userprojectlist stuff

        const userProjects = await factory.methods.getUserProject(accounts[0]).call();
        assert.ok(userProjects[0])
    })






});










































