import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString: String
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterResult))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(presentCredit))
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    // We're ok to parse!
                    self.parse(json: data)
                    return
                }
            }
            self.showError()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteredPetitions[indexPath.row]
        
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = filteredPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            filteredPetitions = petitions
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } 
    }
    
    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func filterResult() {
        let ac = UIAlertController(title: "Filter", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        let clearAction = UIAlertAction(title: "Clear", style: .default) { [weak self] action in
            self?.filteredPetitions = self?.petitions ?? []
            self?.tableView.reloadData()
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let str = ac?.textFields?[0].text else { return }
            self?.filter(byString: str)
        }
        
        ac.addAction(cancelAction)
        ac.addAction(clearAction)
        ac.addAction(submitAction)
        
        present(ac, animated: true)
    }
    
    @objc func presentCredit() {
        let ac = UIAlertController(title: "Credits", message: "Data comes from the 'We the People API' of the Whitehouse", preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default)
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    func filter(byString string: String) {
        filteredPetitions = petitions
        filteredPetitions.removeAll { !$0.title.lowercased().contains(string.lowercased()) && !$0.body.lowercased().contains(string.lowercased())}
        
        tableView.reloadData()
    }
}

