import Cocoa
import Contacts

protocol PhoneNumberProtocol {
    var number: String {get}
    var type: PhoneType {get}
}

enum PhoneType: String {
    case iPhone
    case mobile
    case home
    case other
}

struct PhoneNumber: PhoneNumberProtocol {
    var number: String
    var type: PhoneType
}

protocol AddressProtocol {
    var street: String {get}
    var city: String {get}
    var country: String {get}
}

struct Address: AddressProtocol {
    var street: String
    var city: String
    var country: String
}

protocol ContactProtocol {
    var firstName: String? { get }
    var lastName: String? { get }
    var phones: [PhoneNumberProtocol] { get }
    var addresses: [AddressProtocol] { get }
    var emails: [String] { get }
    var birthday: DateComponents? { get }
}

struct Contact: ContactProtocol {
    var firstName: String?
    var lastName: String?
    var phones: [PhoneNumberProtocol]
    var addresses: [AddressProtocol]
    var emails: [String]
    var birthday: DateComponents?
}

let calendar = Calendar.current
let now = Date()
var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)

func generateContactWith(suffix: String, dateComponents: DateComponents?) -> Contact {
    return Contact(firstName: "firstName" + suffix,
                   lastName: "lastName" + suffix,
                   phones: [PhoneNumber(number: "+77777777777"  + suffix,
                                        type: .iPhone)],
                   addresses: [Address(street: "Street" + suffix,
                                       city: "City" + suffix,
                                       country: "Country" + suffix)],
                   emails: ["firstName" + suffix + ".lastName" + suffix + "@mail.com"],
                   birthday: dateComponents)
}

let contact1 = generateContactWith(suffix: "1", dateComponents: dateComponents)

dateComponents.day = dateComponents.day! + 1
let contact2 = generateContactWith(suffix: "2", dateComponents: dateComponents)

let contact3 = generateContactWith(suffix: "3", dateComponents: dateComponents)

dateComponents.day = dateComponents.day! - 2
let contact4 = generateContactWith(suffix: "4", dateComponents: dateComponents)

dateComponents.day = 1
dateComponents.month = 1
let contact5 = generateContactWith(suffix: "5", dateComponents: dateComponents)

dateComponents.day = 31
dateComponents.month = 12
let contact6 = generateContactWith(suffix: "6", dateComponents: dateComponents)

let contact7 = generateContactWith(suffix: "7", dateComponents: nil)

typealias UpcomingBirthday = (Date, [ContactProtocol])

protocol ContactBookProtocol: RandomAccessCollection where Self.Element == ContactProtocol {
    mutating func add(_ contact: ContactProtocol)
    func upcomingBirthdayContacts() -> [UpcomingBirthday]
}

struct ContactBook {
    private var privateStorage = [ContactProtocol]()
    
    enum SortingType {
        case firstName
        case lastName
    }
    
    var sortType = SortingType.firstName {
        didSet {
            sortPrivateStorage()
        }
    }
    
    private mutating func sortPrivateStorage() {
        privateStorage.sort(by: sortingClosure(for: sortType))
    }
    
    private func sortingClosure(for sortingType: SortingType) -> ((ContactProtocol, ContactProtocol) -> Bool) {
        switch sortingType {
        case .firstName: return { type(of: self).isLessThan($0.firstName, $1.firstName) }
        case .lastName: return { type(of: self).isLessThan($0.lastName, $1.lastName) }
        }
    }
    
    private static func isLessThan(_ lhs: String?, _ rhs: String?) -> Bool {
        switch (lhs, rhs) {
        case let (l?, r?):
            return l.caseInsensitiveCompare(r) == .orderedAscending
        case (nil, _?):
            return true
        default:
            return false
        }
    }
}

extension ContactBook: CustomDebugStringConvertible {
    var debugDescription: String {
        return self.reduce(into: "ContactBook:\n") {
            result, anotherContact in
            
            let birthdayString: String
            if let birthday = anotherContact.birthday {
                birthdayString = String(describing: birthday)
            } else {
                birthdayString = ""
            }
            
            if anotherContact.firstName == "" && anotherContact.lastName == "" {
                result += "\tunnamed contact \(birthdayString)\n"
            } else {
                result += "\t\(anotherContact.firstName ?? "") \(anotherContact.lastName ?? "") \(birthdayString)\n"
            }
        }
    }
}

extension ContactBook: RandomAccessCollection {
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return privateStorage.count
    }
    
    func index(after i: Int) -> Int {
        return i + 1
    }
    
    subscript(position: Int) -> ContactProtocol {
        return privateStorage[position]
    }
}

extension Collection {
    func grouped<Key: Equatable>(by getKey:(_ element: Self.Element) -> Key?) -> [(Key, [Self.Element])]{
        var result: [(Key, [Self.Element])] = []
        
        for element in self {
            guard let keyForElement = getKey(element) else {
                continue
            }
            
            let index = result.index {
                (key: Key, elements: [Self.Element]) in
                
                keyForElement == key
            }
            
            if let index = index {
                result[index].1.append(element)
            } else {
                result.append((keyForElement, [element]))
            }
        }
        
        return result
    }
}

extension ContactBook: ContactBookProtocol {
    mutating func add(_ contact: ContactProtocol) {
        let index = privateStorage.index { sortingClosure(for: sortType)(contact, $0) }
        
        privateStorage.insert(contact, at: index ?? privateStorage.endIndex)
    }
    
    func upcomingBirthdayContacts() -> [UpcomingBirthday] {
        let todayComponents = Calendar.current.dateComponents([.day, .month], from: Date())
        guard let todayDayMonthDate = Calendar.current.date(from: todayComponents) else {
            return [UpcomingBirthday]()
        }
        
        let sortedBirthdays = grouped {
            (anotherContact: ContactProtocol) -> Date? in
            
            guard var birthday = anotherContact.birthday else {
                return nil
            }
            
            let dayMonthComponents = DateComponents(month: birthday.month, day: birthday.day)
            
            return Calendar.current.date(from: dayMonthComponents)
        }.sorted {
            $0.0 < $1.0
        }
        
        let previousBirthdays = sortedBirthdays.prefix(while: {
            $0.0 < todayDayMonthDate
        })
        
        let result = sortedBirthdays.dropFirst(previousBirthdays.count) + previousBirthdays
        
        return [UpcomingBirthday](result.prefix(3))
    }
}

var contactBook = ContactBook()

contactBook.add(contact7)
contactBook.add(contact6)
contactBook.add(contact5)
contactBook.add(contact4)
contactBook.add(contact3)
contactBook.add(contact2)
contactBook.add(contact1)

print("\(contactBook)")

let authStatus = CNContactStore.authorizationStatus(for: .contacts)
if .notDetermined == authStatus {
    let store = CNContactStore()
    store.requestAccess(for: .contacts) {
        (access, accessError) in
        
        if access {
            print("Access granted")
        } else {
            print("Access denied. Reason: \(String(describing: accessError))")
        }
    }
} else if .denied == authStatus {
    print("Access has already denied")
} else {
    print("Access has already granted")
}

struct CNPostalAddressWrapper: AddressProtocol {
    private let address: CNLabeledValue<CNPostalAddress>
    
    init(_ address: CNLabeledValue<CNPostalAddress>) {
        self.address = address
    }
    
    var street: String {
        return self.address.value.street
    }
    
    var city: String {
        return self.address.value.city
    }
    
    var country: String {
        return self.address.value.country
    }
}

struct CNPhoneNumberWrapper: PhoneNumberProtocol {
    private let phone: CNLabeledValue<CNPhoneNumber>
    
    init(_ phone: CNLabeledValue<CNPhoneNumber>) {
        self.phone = phone
    }
    
    var number: String {
        return phone.value.stringValue
    }
    
    var type: PhoneType {
        guard let label = self.phone.label else {
            return .other
        }
        
        return PhoneType(rawValue: label) ?? .other
    }
}

extension CNContact: ContactProtocol {
    var firstName: String? {
        return givenName
    }
    
    var lastName: String? {
        return familyName
    }
    
    var phones: [PhoneNumberProtocol] {
        return phoneNumbers.map(CNPhoneNumberWrapper.init)
    }
    
    var addresses: [AddressProtocol] {
        return postalAddresses.map(CNPostalAddressWrapper.init)
    }
    
    var emails: [String] {
        return emailAddresses.map{ $0.value as String }
    }
}

let store = CNContactStore()
let keys = [CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactPostalAddressesKey,
            CNContactBirthdayKey] as [CNKeyDescriptor]
let request = CNContactFetchRequest(keysToFetch: keys)

try? store.enumerateContacts(with: request) {
    (contact: CNContact, _: UnsafeMutablePointer<ObjCBool>) in
    
    contactBook.add(contact as ContactProtocol)
}

print("\(contactBook)")

let birthdays = contactBook.upcomingBirthdayContacts()

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "dd MMMM"

for (date, contacts) in birthdays {
    print(dateFormatter.string(from: date))
    
    for contact in contacts {
        print("\t\(contact.firstName ?? "") \(contact.lastName ?? "")")
    }
}
