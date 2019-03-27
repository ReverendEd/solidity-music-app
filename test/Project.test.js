const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3'); //full class
const web3 = new Web3(ganache.provider());

const compiledProjectFactory = require('../ethereum/build/ProjectFactory.json');
const compiledProject = require('../ethereum/build/Project.json');
const compiledRound = require('../ethereum/build/Round.json')

let accounts;
let factory;
let projects;
let thisProject;

beforeEach(async () => {
    accounts = await web3.eth.getAccounts();

    factory = await new web3.eth.Contract(JSON.parse(compiledProjectFactory.interface))
        .deploy({ data: compiledProjectFactory.bytecode })
        .send({ from: accounts[0], gas: '4000000' })

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
    
    projects = await factory.methods.getDeployedProjects().call()
    thisProject = await new web3.eth.Contract(JSON.parse(compiledProject.interface), projects[0])
})

describe('Project', () => {
    const r = web3.utils.fromAscii
    let currentRound;
    it('deploys a project', () => {
        assert.ok(thisProject)
    })

    it('correctly sets manager', async ()=>{
        let params = await thisProject.methods.params().call()      
        assert.equal(params.ownerAddress, accounts[0])
    })

    it('makes and returns rounds', async()=>{
        currentRound = await thisProject.methods.getCurrentRound().call()
        assert.ok(currentRound)
    })

    it('allows users to submit and retrieve changes', async()=>{
        await thisProject.methods.submitChange(r('test-change'), r('test-change'))
        let round = await new web3.eth.Contract(JSON.parse(compiledRound.interface), currentRound)
        let change = await round.methods.changePoolList(0).call()
        console.log(change);
        assert.ok(change)
    })

    it('bans users', async()=>{
        await thisProject.methods.banAddress(accounts[1]).send({
            from: accounts[0],
            gas: '4000000'
        })
        let bannedUser = await thisProject.methods.filterList(0).call()
        assert.equal(bannedUser, accounts[1])
    })


})