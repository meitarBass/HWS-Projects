import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var interestName: UILabel!
    @IBOutlet var interestImage: UIImageView!
    
    var imagePath: URL?
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        interestName.text = "\(text ?? "")"
        
        if let path = imagePath {
            interestImage.image = UIImage(contentsOfFile: path.path)
        }
    }
}
