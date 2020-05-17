class Player {
    let name: String
    let age: Int
    let game: String
    
    var playerInfo: String {
        let playerInfo = """
        Player name is \(name).
        He plays \(game).
        He is \(age) years old.
        """
        return playerInfo
    }
    
    init(name: String, game: String, age:Int) {
        self.name = name
        self.game = game
        self.age = age
    }
}

protocol PolitePlayer {
    var friends: [Player] { get }
    var haveaFriend: Bool { get }
    
    func smile()
    func apologize() -> String
}

class ProfessionalPlayer: Player {
    let experience: Int
    let retirementAge: Int
    
    init(name: String, game: String, age: Int, experience: Int, retirementAge: Int) {
        self.experience = experience
        self.retirementAge = retirementAge
        super.init(name: name, game: game, age: age)
    }
}

extension ProfessionalPlayer: PolitePlayer {
    var friends: [Player] {
        return [Player(name: "Ann", game: "Football", age: 22)]
    }
    
    var haveaFriend: Bool {
        return !friends.isEmpty
    }
    
    func smile() {
        print("Let's smile together")
    }
    
    func apologize() -> String {
        return "Sorry, friend!"
    }
}

let player = Player(name: "Alex", game: "Football", age: 12)
print(player.playerInfo)

let proPlayer = ProfessionalPlayer(name: "Misha", game: "Apex", age: 28, experience: 10, retirementAge: 40)
print(proPlayer.playerInfo)

proPlayer.apologize()

