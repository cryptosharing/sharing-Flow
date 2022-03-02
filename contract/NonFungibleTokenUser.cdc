/**

## The Flow Non-Fungible Token User standard, is a extension of Non-Fungible Token standard.

## `ExampleNFT` contract interface

Their contract would have to follow all the rules and naming
that the interface specifies.

*/

pub contract interface NonFungibleTokenUser{
    // Event that is emitted when a token-user is withdrawn,
    // If the collection is not in an account's storage, `from` will be `nil`.
    //
    pub event WithdrawUser(id: UInt64, from: Address?) 

    // Event that emitted when a token is deposited to a collection.
    //
    pub event DepositUser(id: UInt64, to: Address?)

    // Event that emitted when a NFTUser is created
    //
    pub event CreateNFTUser(id: UInt64 , expTime: UInt64)

    pub resource NFTUser {
        // The ID same as the ownedNFT
        pub let id: UInt64

        // The user's use deadline
        pub let expTime: UInt64
    }

    //Interface to deposits NFTUser to the Collection
    //
    pub resource interface NFTUserReceiver{
        // deposit takes an NFTUser as an argument and adds it to the Collection
        //
        pub fun depositUser(token: @NFTUser)

    }

    // Interface to withdraws NFTUser from the Collection
    //
    pub resource interface NFTUserProvider{
        // removes an NFTUser from the collection and moves it to the caller
        pub fun withdrawUser(withdrawID: UInt64): @NFTUser {
            post{
                result.id == withdrawID: "The ID of the withdrawn token must be the same as the requested ID"
                result.expTime <= getCurrentBlock().height: "you can't withdraw the overtime NFTUser"
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
        pub fun createNFTUser(NFTID: UInt64 , expTime: UInt64): @NFTUser {
            pre{
                self.idExists(id:NFTID)&&(self.getUserExpired(id: NFTID) == 0 || self.getUserExpired(id: NFTID) <= getCurrentBlock().height): "no access to create NFTUser"
            }
        }
    }
    
    // Interface that an account would commonly 
    // publish for their collection
    pub resource interface UserCollectionPublic {

        // getUserIDs returns an array of the UserIDs that are in the collection
        pub fun getUserIDs(): [UInt64]

        // idUserExists checks to see if a NFTUser 
        // with the given ID exists in the collection
        pub fun idUserExists(id: UInt64): Bool

        //getUserExpired returns the special id user NFT's use deadline
        pub fun getUserExpired(id: UInt64): UInt64
    }


}
