import UIKit

class CountryViewController: UIViewController {
    
    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var flagImageView: UIImageView!
    
    
    var country: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let country = country else {
            return
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        countryLabel.text = "\(country.uppercased())"
        flagImageView.image = UIImage(named: country)
        flagImageView.layer.borderColor = UIColor.darkGray.cgColor
        flagImageView.layer.borderWidth = 2.0
    }
    
    @objc func shareTapped() {
        guard let image = flagImageView.image?.jpegData(compressionQuality: 0.8) else {
            print("No image found")
            return
        }
        
        guard let imageName = country else {
            return
        }
        
        let vc = UIActivityViewController(activityItems: [image, imageName.uppercased()], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }


}
