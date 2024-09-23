
import UIKit

class Interests: NSObject, NSSecureCoding {

    var label: String
    var image: String
    
    init(label: String, image: String) {
        self.label = label
        self.image = image
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    required init(coder aDecoder: NSCoder) {
        label = aDecoder.decodeObject(forKey: "label") as? String ?? ""
        image = aDecoder.decodeObject(forKey: "image") as? String ?? ""
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(label, forKey: "label")
        aCoder.encode(image, forKey: "image")
    }
    
}
