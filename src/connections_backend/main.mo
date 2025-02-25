import Iter "mo:base/Iter";
import Trie "mo:base/Trie";
import Nat32 "mo:base/Nat32";
import Option "mo:base/Option";



actor User {
  //define user id as Nat32
   public type UserId = Nat32;

  //define the structure of users
   public type Users = {
      firstname: Text;
      lastname: Text;
      email: Text;
   };

  // stable var for generating user ids -> stable to persist throughout the smart contract invocation
   private stable var id: UserId = 0; 

   // stable var for storing user data in a Trie(key value store)

   private stable var users: Trie.Trie<UserId, Users> = Trie.empty();


  //public func to create users Id
   public func created(user: Users) : async UserId {

    //create a new user based on the unique id
      let user_id = id;

      //creating room for new users
      id += 1;

      //storing users info safely using the trie and binding it to the id
      users := Trie.replace(
        users,             // Current Trie
        key(user_id),       // Key to insert/replace
        Nat32.equal,
        ?user             // Value (user data) to associate with the key
               // Equality function for key comparison
      ).0;                 // Extract the updated Trie from the result tuple

      return user_id;  // Return the new user ID
   };


    //read users info
   public func read(user_id: UserId) : async ?Users {
      let result = Trie.find(users, key(user_id), Nat32.equal);
      return result;
   };

     public func readAll(user_id: UserId) : async [(UserId, Users)] {

      //return all users data as a list of tuples (UserId, Users)
      let resultAllData = Iter.toArray(Trie.iter(users));
      //filter the data to only include the user with the given id
      return resultAllData;
   };

  public func update(user_id: UserId, userinput: Users): async Bool {
    //find data we want to update
    let resultUser = Trie.find(users, key(user_id), Nat32.equal);

    let data = Option.isSome(resultUser);

    if(data) {
     users := Trie.replace(
        users,             // Current Trie
        key(user_id),       // Key to insert/replace
        Nat32.equal,
        ?userinput,            // Value (user data) to associate with the key
               // Equality function for key comparison
      ).0;                 // Extract the updated Trie from the result tuple

    };

    return data;
  };

  //generate a key to be used in the trie
   private func key(x : UserId) : Trie.Key<UserId> {
      return {hash = x; key = x};  // Create a Trie Key from the UserId
   };
};
