//import NonFungibleToken from "./NonFungibleToken.cdc"
import NonFungibleToken from 0x01
import NonFungibleTokenUser from 0x02

pub contract ExampleNFT :NonFungibleToken,NonFungibleTokenUser{
    pub var totalSupply: UInt64

    pub event ContractInitialized()

    pub event Withdraw(id: UInt64, from: Address?)

    pub event WithdrawUser(id: UInt64, from: Address?)

    pub event Deposit(id: UInt64, to: Address?)

    pub event DepositUser(id: UInt64, to: Address?)

    pub event CreateUserNFT(id: UInt64 , expTime: UInt64)

    pub let CollectionStoragePath: StoragePath

    pub let CollectionReceiverPath: PublicPath

    pub let CollectionUserReceiverPath: PublicPath

    pub let MinterStoragePath: StoragePath

    pub resource UserNFT{

        pub let id: UInt64
        pub let expTime: UInt64

        // Initialize both fields in the init function
        init(initID: UInt64,initExpTime: UInt64) {
            self.id = initID
            self.expTime = initExpTime
        }
    }

    // Declare the NFT resource type
    pub resource NFT: NonFungibleToken.INFT{
        // The unique ID that differentiates each NFT
        pub let id: UInt64

        // Initialize both fields in the init function
        init(initID: UInt64) {
            self.id = initID
        }
    }

    pub resource interface Create{
        pub fun createUserNFT(NFTID: UInt64 , expTime: UInt64): @NonFungibleTokenUser.UserNFT
    }

    // The definition of the Collection resource that
    // holds the NFTs that a user owns
    pub resource Collection: NonFungibleToken.Provider,NonFungibleToken.Receiver,NonFungibleToken.CollectionPublic,NonFungibleTokenUser.NFTUserProvider,NonFungibleTokenUser.NFTUserReceiver,NonFungibleTokenUser.UserCollectionPublic,Create{
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        // dictionary of userNFT conforming tokens
        pub var userNFTs: @{UInt64: NonFungibleTokenUser.UserNFT}

        // dictionary of NFTID and its expTime
        access(contract) let expired: {UInt64: UInt64}

        // Initialize the NFTs field to an empty collection
        init () {
            self.ownedNFTs <- {}
            self.userNFTs <- {}
            self.expired = {}
        }
        
        // withdraw 
        //
        // Function that removes an NFT from the collection 
        // and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            
            assert(self.expired[withdrawID] == nil || self.expired[withdrawID]! <= getCurrentBlock().height,message:"no access")

            let token <- self.ownedNFTs.remove(key: withdrawID)!

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <- token
        }

        // withdraw removes an userNFT from the collection and moves it to the caller
        pub fun withdrawUser(withdrawID: UInt64): @NonFungibleTokenUser.UserNFT {
            post {
                result.expTime <= getCurrentBlock().height: "you can't auth"
            }
            let token <- self.userNFTs.remove(key: withdrawID)!

            emit WithdrawUser(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit 
        //
        // Function that takes a NFT as an argument and 
        // adds it to the collections dictionary
        pub fun deposit(token: @NonFungibleToken.NFT) {
           
            emit Deposit(id: token.id, to: self.owner?.address)

            // add the new token to the dictionary with a force assignment
            // if there is already a value at that key, it will fail and revert
            self.ownedNFTs[token.id] <-! token
        }

        // deposit takes an userNFT as an argument and adds it to the collections dictionary
        pub fun depositUser(token: @NonFungibleTokenUser.UserNFT) {
            if self.userNFTs[token.id] != nil {
                destroy self.userNFTs.remove(key: token.id)!
            } 

            emit DepositUser(id: token.id, to: self.owner?.address)

            self.userNFTs[token.id] <-! token
        }

        // idExists checks to see if a NFT 
        // with the given ID exists in the collection
        pub fun idExists(id: UInt64): Bool {
            return self.ownedNFTs[id] != nil
        }

        // idUserExists checks to see if a userNFT 
        // with the given ID exists in the collection
        pub fun idUserExists(id: UInt64): Bool {
            return self.userNFTs[id] != nil
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // getUserIDs returns an array of the UserIDs that are in the collection
        pub fun getUserIDs(): [UInt64] {
            return self.userNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        //getUserExpired can get contract userNFT's expTime with id
        pub fun getUserExpired(id: UInt64): UInt64 {
            return self.expired[id]!
        }

        pub fun createUserNFT(NFTID: UInt64 , expTime: UInt64): @NonFungibleTokenUser.UserNFT {
            assert(self.idExists(id:NFTID)&&(self.expired[NFTID] == nil || self.expired[NFTID]! <= getCurrentBlock().height),message:"no access")
            var newUserNFT <- create UserNFT(initID: NFTID , initExpTime: expTime)
            emit CreateUserNFT(id: NFTID, expTime: expTime)
            self.expired[NFTID] = expTime
            return <- newUserNFT
        }

        destroy() {
            destroy self.ownedNFTs
            destroy self.userNFTs
        }

    }

    // creates a new empty Collection resource and returns it 
    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }



    // NFTMinter
    //
    // Resource that would be owned by an admin or by a smart contract 
    // that allows them to mint new NFTs when needed
    pub resource NFTMinter {
        // mintNFT 
        //
        // Function that mints a new NFT with a new ID
        // and returns it to the caller
        pub fun mintNFT(): @NFT {

            // create a new NFT
            var newNFT <- create NFT(initID: ExampleNFT.totalSupply)

            // change the id so that each ID is unique
            ExampleNFT.totalSupply = ExampleNFT.totalSupply + 1 

            return <- newNFT
        }
    }

	init(){
        self.totalSupply = 0
        self.CollectionStoragePath = /storage/NFTCollection
        self.CollectionReceiverPath = /public/NFTReceiver
        self.CollectionUserReceiverPath = /public/NFTUserReceiver
        self.MinterStoragePath = /storage/NFTMinter
		// store an empty NFT Collection in account storage
        self.account.save(<-self.createEmptyCollection(), to: self.CollectionStoragePath)

        // publish a reference to the Collection in storage
        self.account.link<&{NonFungibleToken.Receiver}>(self.CollectionReceiverPath, target: self.CollectionStoragePath)

        self.account.link<&{NonFungibleTokenUser.NFTUserReceiver}>(self.CollectionUserReceiverPath,target: self.CollectionStoragePath)
	
        // store a minter resource in account storage
        self.account.save(<-create NFTMinter(), to: self.MinterStoragePath)
	}
}
