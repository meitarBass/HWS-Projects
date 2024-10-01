import UIKit

class ViewController: UITableViewController {
    
    var countries = [Country]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Countries"
        navigationController?.navigationBar.prefersLargeTitles = true
        loadCountries()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? CountryDetailViewController {
            vc.country = countries[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "country", for: indexPath)
        
        cell.textLabel?.text = countries[indexPath.row].name
        return cell
    }
    
    
    func loadCountries() {
        if let url = Bundle.main.url(forResource: "countries", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                
                let decoder = JSONDecoder()
                let countriesData = try decoder.decode(Countries.self, from: data)
                
                countries = countriesData.countries
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
    }


}

