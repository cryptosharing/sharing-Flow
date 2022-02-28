/**

## The Flow Non-Fungible Token standard

## `NonFungibleToken` contract interface

Their contract would have to follow all the rules and naming
that the interface specifies.

*/

pub contract interface NonFungibleTokenUser{

    // Event that emitted when the NFT contract is initialized
    //
    pub event ContractInitialized()

    // Event that is emitted when a token-user is withdrawn,
    // If the collection is not in an account's storage, `from` will be `nil`.
    //
    pub event WithdrawUser(id: UInt64, from: Address?) 

    // Event that emitted when a token is deposited to a collection.
    //
    pub event DepositUser(id: UInt64, to: Address?)

    // Event that emitted when a userNFT is created
    //
    pub event CreateUserNFT(id: UInt64 , expTime: UInt64)

    pub resource UserNFT {
        // The ID same as the ownedNFT
        pub let id: UInt64

        // The user's use deadline
        pub let expTime: UInt64
    }

    //Interface to deposits to the Collection
    //
    pub resource interface NFTUserReceiver{
        // deposit takes an userNFT as an argument and adds it to the Collection
        //
        pub fun depositUser(token: @UserNFT)

    }

    // Interface to withdraws from the Collection
    //
    pub resource interface NFTUserProvider{
        // withdraw removes an userNFT from the collection and moves it to the caller
        pub fun withdrawUser(withdrawID: UInt64): @UserNFT {
            post{
                result.id == withdrawID: "The ID of the withdrawn token must be the same as the requested ID"
                result.expTime <= getCurrentBlock().height: "you can't auth"
            }
        }
    }
    
    // Interface to create user 
    //
    pub resource interface NFTUserCreate{

        //getUserExpired returns the special id NFT's use deadline
        pub fun getUserExpired(id: UInt64): UInt64

        // idExists checks to see if a NFT with the given ID exists in the collection
        pub fun idExists(id: UInt64): Bool

        // create a user in the special NFTID with the expTime
        // precondition is the NFTID in this Collection and the special NFTID's user is out of deadline or no user before
        pub fun createUserNFT(NFTID: UInt64 , expTime: UInt64): @UserNFT {
            pre{
                self.idExists(id:NFTID)&&(self.getUserExpired(id: NFTID) == 0 || self.getUserExpired(id: NFTID) <= getCurrentBlock().height): "no access"
            }
        }
    }
    
    // Interface that an account would commonly 
    // publish for their collection
    pub resource interface UserCollectionPublic {

        // getUserIDs returns an array of the UserIDs that are in the collection
        pub fun getUserIDs(): [UInt64]

        // idUserExists checks to see if a userNFT 
        // with the given ID exists in the collection
        pub fun idUserExists(id: UInt64): Bool

        //getUserExpired returns the special id user NFT's use deadline
        pub fun getUserExpired(id: UInt64): UInt64
    }


}
