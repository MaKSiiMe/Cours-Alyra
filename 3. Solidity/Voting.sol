// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {

    // Le vote n'est pas secret
    // Chaque électeur peut voir les votes des autres
    // Le gagnant est déterminé à la majorité simple
    // La proposition qui obtient le plus de voix l'emporte.

    struct Voter {
        bool isRegistered; // Si bool == true, alors Voter est bien enregistré
        bool hasVoted; // Si bool == true, alors Voter à bien voté
        uint votedProposalId; // vote "proposal" de Voter
    }
    
    mapping(address => Voter) public Voters; // déclaration d'une variable d'état qui stocke une structure Voter pour chaque adresse
    
    struct Proposal {
        string description;
        uint voteCount; // Nombre de vote cumulé
    }

    // address public whitelist;   MODIFIER !!!
    
    Proposal[] public proposal; // Tableau dynamique "proposal" contenant des structures "Proposal"

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    WorkflowStatus public newStatus;


    /*
    
    Voici le déroulement de l'ensemble du processus de vote :

    1 - L'administrateur du vote enregistre une liste blanche d'électeurs identifiés par leur adresse Ethereum.
    2 - L'administrateur du vote commence la session d'enregistrement de la proposition.
    3 - Les électeurs inscrits sont autorisés à enregistrer leurs propositions pendant que la session d'enregistrement est active.
    4 - L'administrateur de vote met fin à la session d'enregistrement des propositions.
    5 - L'administrateur du vote commence la session de vote.
    6 - Les électeurs inscrits votent pour leur proposition préférée.
    7 - L'administrateur du vote met fin à la session de vote.
    8 - L'administrateur du vote comptabilise les votes.
    9 - Tout le monde peut vérifier les derniers détails de la proposition gagnante.
    
    */


    // =============================================== Début du processus de voting (Workflow Partie 1) =============================================== //

    function startRegisteringVoters() external onlyOwner {
        WorkflowStatus.RegisteringVoters;
    }

    // Permet de savoir si le "WorkflowStatus" est en mode "RegisteringVoters" pour la fonction suivante

    modifier IfRegisteringVoters() {
        require (newStatus == WorkflowStatus.RegisteringVoters); 
        _;
    }

    // 1 - Enregistrement de la whitelist d'électeur avec l'adresse Ethereum "_voter"

    function addVoter(address _voter) external onlyOwner IfRegisteringVoters {
        require (Voters[_voter].isRegistered == false);
        Voters[_voter].isRegistered = true;
    }

    // Vérifie si l'adresse d'un votant est déjà enregistrée

    function isRegisteredVoter(address _voter) external view returns(bool) {
        return Voters[_voter].isRegistered;
    }

    // =========================================== Début de la session d'enregistrement (WorkFlow Partie 2) =========================================== //

    // 2 - Enregistrement des proposition

    function startProposalsRegistrationStarted() external onlyOwner IfRegisteringVoters {
        newStatus = WorkflowStatus.ProposalsRegistrationStarted;
    }

    // Permet de savoir si le "WorkflowStatus" est en mode "ProposalsRegistrationStarted" pour la fonction suivante, commme précédemment

    modifier IfProposalsRegistrationStarted() {
        require (newStatus == WorkflowStatus.ProposalsRegistrationStarted); 
        _;
    }

    // 3 - Ajout des proposation de vote à la fin du tableau "proposal" déclaré au début du "contract"

    function createProposal(string memory _description) public IfProposalsRegistrationStarted {
        proposal.push (Proposal(_description,0));
    }

    // 4 - Fin de la session d'enregistrement des propositions (WorkFlow Partie 3)


    // ================================================ Début de la session de vote (WorkFlow Partie 4) ================================================ //

    // 5 - Démarrage des votes

    function starVotingSessionStarted() external onlyOwner IfProposalsRegistrationStarted {
            newStatus = WorkflowStatus.VotingSessionStarted;
    }

    // Permet de savoir si le "WorkflowStatus" est en mode "VotingSessionStarted" pour la fonction suivante, commme précédemment

    modifier ifVotingSessionStarted() {
        require (newStatus == WorkflowStatus.VotingSessionStarted);
        _;
    }

    // 6 - Les électeurs inscrits votent pour leur proposition préférée.

    function vote( uint _proposalid ) external ifVotingSessionStarted{
        address _address = msg.sender;
        require(Voters[_address].isRegistered,"l'adresse n'est pas enregistrée");
        require(!Voters[_address].hasVoted, 'A voté!');
        proposal[_proposalid].voteCount++; // Nombre de vote cumulé
        Voters[_address].hasVoted=true;
    }

    // 7 - L'administrateur du vote met fin à la session de vote.

    // ================================================= fin du processus de vote (WorkFlow Partie 6) ================================================= //

    // 8 - Retourne ne nombre de propositions

    function nbrProposals() public view returns (uint) {
        return proposal.length;
    }

    // 9 - Tout le monde peut vérifier les derniers détails de la proposition gagnante.
    
    function startProposalsRegistrationStarted() external onlyOwner IfRegisteringVoters {
        newStatus = WorkflowStatus.ProposalsRegistrationStarted;
    }

    VotesTallied


    

    function seeVotes() public view returns(uint[] memory) {
        uint longueur = proposal.length;
        uint[] memory winningProposalId = new uint[](longueur);

        for (uint i=0 ; i<proposal.length ; i++){
            winningProposalId[i] = proposal[i].voteCount;
        }
    }
    
    return winningProposalId;
}






    uint winningProposalId;


    event VoterRegistered(address voterAddress);

    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);

    event ProposalRegistered(uint proposalId);

    event Voted (address voter, uint proposalId);

}