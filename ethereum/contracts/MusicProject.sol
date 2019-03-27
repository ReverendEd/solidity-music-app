pragma solidity ^0.4.25;


// IMPORTANT 
// SET BOUNDS TO ALL VARIABLES TO REMOVE THE INFINITE GAS ESTIMATION
// convert strings to bytes32 as well as make the damn thing deploy

//import "./Round.sol";

contract ProjectFactory {
    
    address[] public deployedProjects;
    mapping(address=>bytes32) public users;
    mapping(address=>address[]) public projects;
    // put all the configurable options here modifiable with contructor? 
    
    // thoughts: 2 subrounds, changes and votes
    // deincentivize:
        // making changes too quickly
        // making random changes 
        // voting randomly on as many projects as possible      
        // changing their votes to the winning change           :can't see other peoples votes until the end of the round
    
    
      // convert this to have array of keys for projects and mapping to get projects????
      // convert all address refs for contracts to just contract instances
      // pass contract refs down to child contracts so they can retrieve users from ProjectFactory.
    
    
    function createProject(bytes32 projectName, bytes32 description, bytes32 tags, uint8 totalRounds, bytes32 starterFile, uint8 filterType, address[] memory filterList) public  payable {
        require(totalRounds < 5 && msg.value > 5);
        require(users[msg.sender].length != 0);
        Project project = new Project(projectName, description, msg.sender, users[msg.sender], tags, totalRounds, starterFile, filterType, filterList, this);
        //address(project).transfer(msg.value);
        projects[msg.sender].push(address(project));
        deployedProjects.push(address(project));
    }
    
    function findUser(address user) public view returns(bytes32) {
        return users[user];
    }
    
    function getDeployedProjects() public view returns (address[] memory){
        return deployedProjects;
    }
    
    function registerUser(bytes32 name) public {
        if(users[msg.sender] == 0 ){
            users[msg.sender] = name;
        }

        //users[msg.sender] = name;
    }
    
    function getUserProject(address user) public view returns (address[] memory){
        return projects[user];
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
        ProjectFactory factoryRef;
    }
    
    uint    roundNumber;
    Round[] finishedRounds; //define Round
    bytes32  state;           // state is the project file link
    Round   currentRound;
    bool   public  active = true;
    Preview preview;
    Params public params;
    uint8    filterType; // 1 = whitelist filter, 0 = blacklist filter
    address[] public filterList;
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
    
    
    constructor(bytes32 projectName, bytes32 description, address ownerAddress, bytes32 ownerName, bytes32 tags, uint totalRounds, bytes32 starterFile, uint8 filterTypeFRC, address[] memory filterListFRC, ProjectFactory factory) public payable {
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
            factoryRef: factory
        });
        filterType = filterTypeFRC;
        filterList = filterListFRC;
        for(uint i = 0; i < filterList.length; i++){
            filterMap[filterList[i]] = true;
        }
        currentRound = new Round(roundNumber, state, preview.demo, params.rewardPerRound);
        //currentRound.transfer(params.rewardPerRound);
    }
    
    function submitChange(bytes32 incomingState, bytes32 incomingDemo) public filter isActive {
        Round round = Round(currentRound);
        round.submitChange(incomingState, incomingDemo, msg.sender, params.factoryRef.findUser(msg.sender));
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
            currentRound = new Round(roundNumber, state, preview.demo, params.rewardPerRound);
            //addresspayable(currentRound).transfer(params.rewardPerRound);
        }
        else if(roundNumber >= params.totalRounds){
            finishProject();
        }
    }
    
    function finishProject() private isActive view returns(bytes32) {
        active == false;
        return 'Project has Finished!';
        // we need to handle payments here with payment objects.
    }
    
    function getCurrentRound() view public returns (Round){
        return currentRound;
    }
    
    function getFinishedRounds() view public returns (Round[] memory){
        return finishedRounds;
    }
    
}

contract Round {
    
    struct Change {
        uint    votes;
        bytes32  state;
        bytes32  demo;
        address  creator;
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
    
    function submitChange(bytes32 incomingState, bytes32 incomingDemo, address sender, bytes32 owner) public isActive restricted {
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