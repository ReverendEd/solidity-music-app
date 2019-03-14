pragma solidity ^0.4.22;
pragma experimental ABIEncoderV2;

// IMPORTANT 
// SET BOUNDS TO ALL VARIABLES TO REMOVE THE INFINITE GAS ESTIMATION
// convert strings to bytes32 as well as make the damn thing deploy

import "./Round.sol";

contract ProjectFactory {
    
    address[] public deployedProjects;
    mapping(address=>User) public users;
    // put all the configurable options here modifiable with contructor? 
    
    // thoughts: 2 subrounds, changes and votes
    // deincentivize:
        // making changes too quickly
        // making random changes 
        // voting randomly on as many projects as possible      
        // changing their votes to the winning change           :can't see other peoples votes until the end of the round
    
    struct User {
        bytes32 name;
        address[] projects;
    }
    
    
    function createProject(bytes32 projectName, bytes32 description, bytes32 tags, uint8 totalRounds, bytes32 starterFile, uint8 filterType, address[] filterList) public  payable{
        require(totalRounds < 5 && msg.value > 5);
        require(users[msg.sender].name.length != 0);
        address project = new Project(projectName, description, msg.sender, users[msg.sender].name, tags, totalRounds, starterFile, filterType, filterList, this);
        project.transfer(msg.value);
        users[msg.sender].projects.push(project);
        deployedProjects.push(project);
    }
    
    function findUser(address user) public view returns(bytes32) {
        return users[user].name;
    }
    
    function getDeployedProjects() public view returns (address[]){
        return deployedProjects;
    }
    
    function registerUser(bytes32 name) public {
        if(users[msg.sender].name.length == 0 ){
            users[msg.sender].name = name;
        }
    }
    
    function getUserProject(address user) public view returns (address[]){
        return users[user].projects;
    }
    // projectName must be projectName + ownerName before it even gets to this contract
}

contract Project {
    struct Preview {
        uint    timestamp; 
        bytes32  projectName;
        bytes32  description;
        bytes32  ownerName;
        bytes32  demo;        // rendered audio file demo is string for now.
        bytes32  tags; 
    }
    
    struct Params {
        uint    rewardPerRound;
        uint    totalRounds;    // we need to calculate all this somewhere
        bytes32  starterFile;
        address ownerAddress;
        address factoryRef;
    }
    
    uint    roundNumber;
    address[] finishedRounds; //define Round
    bytes32  state;           // state is the project file link
    address   currentRound;
    bool    active = true;
    Preview preview;
    Params  params;
    uint8    filterType; // 1 = whitelist filter, 0 = blacklist filter
    address[] filterList;
    mapping(address=>bool) filterMap;
    
    
    modifier manager(){
        require(msg.sender == params.ownerAddress);
        _;
    }
    
    modifier isActive(){
        require(active == true);
        _;
    }
    
    modifier filter(){
        if(filterType == 1){
            require(filterMap[msg.sender] == true);
            _;
        }
        else {
            require(filterMap[msg.sender] == false);
            _;
        }
    }
    
    
    function Project(bytes32 projectName, bytes32 description, address ownerAddress, bytes32 ownerName, bytes32 tags, uint totalRounds, bytes32 starterFile, uint8 filterTypeFRC, address[] filterListFRC, address factoryRefParam) public payable {
        //require(msg.value > 100);
        roundNumber = 1;
        state = starterFile;
        preview = Preview({
            timestamp: now,
            projectName: projectName,
            description: description,
            ownerName: ownerName,
            demo: starterFile,
            tags: tags
        });
        params = Params({
            rewardPerRound: msg.value / totalRounds,
            totalRounds: totalRounds,
            starterFile: starterFile,
            ownerAddress: ownerAddress,
            factoryRef: factoryRefParam
        });
        filterType = filterTypeFRC;
        filterList = filterListFRC;
        for(uint i = 0; i < filterList.length; i++){
            filterMap[filterList[i]] = true;
        }
        currentRound = new Round(roundNumber, state, preview.demo, params.rewardPerRound, params.factoryRef);
        currentRound.transfer(params.rewardPerRound);
    }
    
    function submitChange(bytes32 incomingState, bytes32 incomingDemo) public filter isActive {
        Round round = Round(currentRound);
        round.submitChange(incomingState, incomingDemo, msg.sender);
    }
    
    function submitVote(bytes32 incomingChangeID) public filter isActive {
        Round round = Round(currentRound);
        round.submitVote(incomingChangeID, msg.sender);
    }
    
    function banAddress(address bannedUser) public filter isActive manager {
        filterMap[bannedUser] = true;
        filterList.push(bannedUser);
    }
    
    function finishRound() manager isActive public {
        Round round = Round(currentRound);
        round.getWinner();
        state = round.returnWinnerState();
        preview.demo = round.returnWinnerDemo();
        finishedRounds.push(currentRound);
        if(roundNumber < params.totalRounds){
            roundNumber++;
            currentRound = new Round(roundNumber, state, preview.demo, params.rewardPerRound, params.factoryRef);
            currentRound.transfer(params.rewardPerRound);
        }
        else if(roundNumber >= params.totalRounds){
            finishProject();
        }
    }
    
    // function revertRound() manager isActive public {
    //     currentRound = finishedRounds[finishedRounds.length-1];
    //     finishedRounds
    //     roundNumber --;
        
    // }
    
    function finishProject() private isActive view returns(bytes32) {
        active == false;
        return 'Project has Finished!';
        // we need to handle payments here with payment objects.
    }
    
    function getCurrentRound() view public returns (address){
        return currentRound;
    }
    
    function getFinishedRounds() view public returns (address[]){
        return finishedRounds;
    }
    
}