/**

## The Flow Non-Fungible Token standard

## `NonFungibleToken` contract interface

Their contract would have to follow all the rules and naming
that the interface specifies.

*/

pub contract interface NonFungibleToken {

    // The total number of tokens of this type in existence
    pub var totalSupply: UInt64

    // Event that emitted when the NFT contract is initialized
    //
    pub event ContractInitialized()

    // Event that is emitted when a token is withdrawn,
    // indicating the owner of the collection that it was withdrawn from.
    //
    // If the collection is not in an account's storage, `from` will be `nil`.
    //
    pub event Withdraw(id: UInt64, from: Address?)

    // Event that is emitted when a token-user is withdrawn,
    // If the collection is not in an account's storage, `from` will be `nil`.
    //
    pub event WithdrawUser(id: UInt64, from: Address?)

    // Event that emitted when a token is deposited to a collection.
    //
    pub event Deposit(id: UInt64, to: Address?)

    // Event that emitted when a token is deposited to a collection.
    //
    pub event DepositUser(id: UInt64, to: Address?)

    // Event that emitted when a userNFT is created
    pub event CreateUserNFT(id: UInt64 , expTime: UInt64)

    // Interface that the NFTs have to conform to
    //
    pub resource interface INFT {
        // The unique ID that each NFT has
        pub let id: UInt64
    }

    // Requirement that all conforming NFT smart contracts have
    // to define a resource called NFT that conforms to INFT
    pub resource NFT :INFT{
        // The unique ID that differentiates each NFT
        pub let id: UInt64

    }

    pub resource UserNFT :INFT{
        // The ID same as the ownedNFT
        pub let id: UInt64

        // The user's use deadline
        pub let expTime: UInt64
    }

    //Interface to deposits to the Collection
    //
    pub resource interface NFTReceiver {
        // deposit takes an NFT as an argument and adds it to the Collection
        //
        pub fun deposit(token: @NFT)
        // deposit takes an userNFT as an argument and adds it to the Collection
        //
        pub fun depositUser(token: @UserNFT)

    }

    // Interface to withdraws from the Collection
    //
    pub resource interface NFTProvider {
        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NFT {
            post{
                result.id == withdrawID: "The ID of the withdrawn token must be the same as the requested ID"
            }
        }
        // withdraw removes an userNFT from the collection and moves it to the caller
        pub fun withdrawUser(withdrawID: UInt64): @UserNFT {
            post{
                result.id == withdrawID: "The ID of the withdrawn token must be the same as the requested ID"
            }
        }
    }
    

    // Interface that an account would commonly 
    // publish for their collection
    pub resource interface CollectionPublic {

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64]

        // getUserIDs returns an array of the UserIDs that are in the collection
        pub fun getUserIDs(): [UInt64]

        // idExists checks to see if a NFT 
        // with the given ID exists in the collection
        pub fun idExists(id: UInt64): Bool

        // idUserExists checks to see if a userNFT 
        // with the given ID exists in the collection
        pub fun idUserExists(id: UInt64): Bool
    }

    // Requirement for the the concrete resource type
    // to be declared in the implementing contract
    //
    pub resource Collection: NFTProvider, NFTReceiver, CollectionPublic {

        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NFT}

        // dictionary of userNFT conforming tokens
        pub var userNFTs: @{UInt64: UserNFT}

        // dictionary of NFTID and its expTime
        access(contract) let expired: {UInt64: UInt64}

        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NFT

        // withdraw removes an userNFT from the collection and moves it to the caller
        pub fun withdrawUser(withdrawID: UInt64): @UserNFT

        // deposit takes a NFT and adds it to the collections dictionary
        pub fun deposit(token: @NFT)

        // deposit takes an userNFT as an argument and adds it to the collections dictionary
        //
        pub fun depositUser(token: @UserNFT)

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64]

        // getUserIDs returns an array of the UserIDs that are in the collection
        pub fun getUserIDs(): [UInt64]

        // idExists checks to see if a NFT 
        // with the given ID exists in the collection
        pub fun idExists(id: UInt64): Bool

        // idUserExists checks to see if a userNFT 
        // with the given ID exists in the collection
        pub fun idUserExists(id: UInt64): Bool

        // createUserNFT can create a corresponding ID's userNFT with the expTime
        pub fun createUserNFT(NFTID: UInt64 , expTime: UInt64): @UserNFT 

        //getUserExpired can get contract userNFT's expTime with id
        pub fun getUserExpired(id: UInt64): UInt64

    }

    // createEmptyCollection creates an empty Collection
    // and returns it to the caller so that they can own NFTs
    pub fun createEmptyCollection(): @Collection {
        post {
            result.getIDs().length == 0: "The created collection must be empty!"
        }
    }
}
