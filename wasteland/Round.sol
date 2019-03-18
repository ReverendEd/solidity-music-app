pragma solidity ^0.5.5;

contract Round {
    
    struct Change {
        uint    votes;
        bytes32  state;
        bytes32  demo;
        addresspayable creator;
        bytes32  owner;
    }
    
    uint        roundNumber;
    bool        active = true;
    bytes32      startState;
    bytes32      startDemo;
    Change      Winner;
    uint        rewardAmount;
    address     masterProject;
    
    Change[]   public changePoolList;
    mapping(bytes32=>Change) changePoolMap;     // change to find change info 
    address[]   voterPoolList;
    mapping(address=>bytes32) voterPool;     // address of voter to find address of change
    
    modifier isActive(){
        require(active == true);
        _;
    }
      
    modifier restricted(){                      // modifier that ensures that the only party accessing this contract is the Project contract.
        require(msg.sender == masterProject);
        _;
    }
    
    constructor(uint roundNumberFRC, bytes32 stateFRC, bytes32 demoFRC, uint rewardAmountFRC) public payable{ 
        roundNumber = roundNumberFRC;
        startState = stateFRC;
        startDemo = demoFRC;
        rewardAmount = rewardAmountFRC;
        masterProject = msg.sender;
    }
    
    function submitChange(bytes32 incomingState, bytes32 incomingDemo, address payable sender, bytes32 owner) public isActive restricted {
        require(incomingState != startState && incomingDemo != startDemo);
        Change memory incomingChange = Change({
            votes: 0,
            state: incomingState,
            demo: incomingDemo,
            creator: sender,
            owner: owner
        });
        changePoolList.push(incomingChange);
        changePoolMap[incomingState] = incomingChange;
    }
    
    function submitVote(bytes32 incomingChangeID, address sender) public isActive restricted {       // this is the string "state" of the change
        if(voterPool[sender].length != 0){  // if the user has voted
            changePoolMap[voterPool[sender]].votes --;      // decrease the votes of the change they voted for by one
            voterPool[sender] = incomingChangeID;           // set the vote to the incoming change
            changePoolMap[incomingChangeID].votes ++;           // increment the votes of the new change
        }
        else{
            voterPool[sender] = incomingChangeID;           // set the vote to the incoming change
            changePoolMap[incomingChangeID].votes ++;             
            voterPoolList.push(sender);
        }
    }
    
    function getWinner() public isActive restricted payable {
        Change memory mostVotes; 
        for(uint i = 0; i < changePoolList.length; i++){
            if(changePoolList[i].votes > mostVotes.votes){
                mostVotes = changePoolList[i];
            }
        }
        Winner = mostVotes;
        mostVotes.creator.transfer(address(this).balance); // for now the creator of the winning change gets the entire reward
        active = false;
    }
    
    function returnWinnerDemo() public view returns(bytes32){
        return Winner.demo;
    }
    
    function returnWinnerState() public view returns(bytes32){
        return Winner.state;
    }
      
}

