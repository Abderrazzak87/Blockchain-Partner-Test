pragma solidity ^0.5.0;

contract PariSportif {
    
    event HTTPRequest(
        uint id,
        string url,
        string method,
        string parameters
    );
    
    struct User {
        address addr;
        uint pari;
        string winner;
    }

    address _trustedAddress; 
    uint requestsCounter = 0;

    mapping (string => User[]) matches; // matchId => [User]
    mapping (string => uint8) availableMatches; // matchId => 0 - disponible | 1 - locké | 2 - match déjà passé
    mapping (uint => string) requestedResults; // requestId => gameId
    
    //Le contratc est initialisé par une addresse de confiance. 
    constructor(address trustedAddress) public {
        _trustedAddress = trustedAddress;
    }
    
    // Le front end appelle cette méthode quand un User veut participer à une pari
    function join(string matchId, string winner) public payable {
        // vérifier si le match est dispo
        require(availableMatches[matchId] == 0); 
        
        // Ajouter le User à la liste des particiapants
        matches[matchId].push(User(msg.sender, msg.value, winner)); 
    }
    
    // faire appel à l'Oracle pour 
    function resolve(string matchId) public {
        require(availableMatches[matchId] == 0);
        availableMatches[matchId] = 1;
        
        // un ID est généré pour matcher la requête et la response
        uint id = getRequestsID();
        requestedResults[id] = matchId; 
        

        // Emettre un evenement pour pouvoir être intercepté de l'exterieur de la blockchain
        emit HTTPRequest(id, "http://some_api.com/get_winner?", "GET",  matchId); 
    }
    

    // Cette méthode est appelé par l'admin à partir du front end pour distribuer les fonds du pari.
    function distributePrize(uint requestId, string response) public {
        require(msg.sender == _trustedAddress);
        
      
        string memory matchId = requestedResults[requestId];
        string memory winner = parseResponse(response);
        
        /*
           Ici écrire les règles de distubution des gains.
        */
        
        //clean up
        delete requestedResults[requestId];
        availableMatches[matchId] = 2;
    }
    
    // parser la réponse de l'Oracle
    function parseResponse(string response) private pure returns(string) {
        return response;
    }
    
    // Générer un id
    function getRequestsID() private returns(uint) { 
        return ++requestsCounter; 
    }

