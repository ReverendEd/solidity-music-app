pragma solidity ^0.4.22;
pragma experimental ABIEncoderV2;

import "browser/Round.sol";

contract ProjectFactory {
    
    address[] public deployedProjects;
    mapping(address=>string) names;
    
    function createProject(string projectName, string description, string ownerName, string tags, uint totalRounds, string starterFile, uint8 filterType, address[] filterList) public  payable{
        if(keccak256(names[msg.sender]) == keccak256('')){
            names[msg.sender] = ownerName;
        }
        address project = new Project(projectName, description, msg.sender, names[msg.sender], tags, totalRounds, starterFile, filterType, filterList);
        deployedProjects.push(project);
    }
    
    function getDeployedProjects() public view returns (address[]){
        return deployedProjects;
    }
    // handle minimum payment here
    // handle maximum rounds here
    // projectName must be projectName + ownerName before it even gets to this contract
}

contract Project {
    struct Preview {
        uint  timestamp; 
        string  projectName;
        string  description;
        string  ownerName;
        string  demo;        // rendered audio file demo is string for now.
        string  tags; 
        string  id;          // id to get full project from the project factory is projectName + owner
    }
    
    struct Params {
        uint    rewardPerRound;
        uint    totalRounds;    // we need to calculate all this somewhere
        string  starterFile;
        address ownerAddress;
    }
    
    uint    roundNumber;
    address[] finishedRounds; //define Round
    string  state;           // state is the project file link
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
    
    
    constructor(string projectName, string description, address ownerAddress, string ownerName, string tags, uint totalRounds, string starterFile, uint8 filterType, address[] filterList) public payable isActive {
        //require(msg.value > 100);
        roundNumber = 1;
        state = starterFile;
        preview = Preview({
            timestamp: now,
            projectName: projectName,
            description: description,
            ownerName: ownerName,
            demo: starterFile,
            tags: tags,
            id: projectName
        });
        params = Params({
            rewardPerRound: msg.value / totalRounds,
            totalRounds: totalRounds,
            starterFile: starterFile,
            ownerAddress: ownerAddress
        });
        filterType = 0;
        filterList = filterList;
        for(uint i = 0; i < filterList.length; i++){
            filterMap[filterList[i]] = true;
        }
        currentRound = new Round(roundNumber, state, preview.demo, params.rewardPerRound);
    }
    
    function submitChange(string incomingState, string incomingDemo) public filter isActive {
        Round round = Round(currentRound);
        round.submitChange(incomingState, incomingDemo, msg.sender);
    }
    
    function submitVote(string incomingChangeID) public filter isActive {
        Round round = Round(currentRound);
        round.submitVote(incomingChangeID, msg.sender);
    }
    
    function finishRound() manager isActive public {
        Round round = Round(currentRound);
        round.getWinner();
        state = round.returnWinnerState();
        preview.demo = round.returnWinnerDemo();
        finishedRounds.push(currentRound);
        if(roundNumber < params.totalRounds){
            roundNumber++;
            currentRound = new Round(roundNumber, state, preview.demo, params.rewardPerRound);
        }
        else if(roundNumber >= params.totalRounds){
            finishProject();
        }
    }
    
    function finishProject() private isActive view returns(string) {
        active == false;
        return 'Project has Finished!';
    }
    
    function getCurrentRound() view returns(address){
        return currentRound;
    }
    
    function getFinishedRounds() view returns(address[]){
        return finishedRounds;
    }
    
}