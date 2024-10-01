import UIKit

class CountryDetailViewController: UIViewController {
    
    var country: Country?

    @IBOutlet var area: UILabel!
    @IBOutlet var continent: UILabel!
    @IBOutlet var currency: UILabel!
    @IBOutlet var gba: UILabel!
    @IBOutlet var population: UILabel!
    
    @IBOutlet var generalInfo: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let country = country else { return }
        
        title = country.name
        area.text = "\(country.area)"
        continent.text = "\(country.continent)"
        currency.text = "\(country.currency)"
        gba.text = "\(country.gba)"
        population.text = "\(country.population)"
        
        generalInfo.text = "\(country.general_information[0])"
    }
}
