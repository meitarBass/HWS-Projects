import UIKit

class ViewController: UITableViewController {
    
    var items = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Grocery List"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newItem))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(share))
    }
}

extension ViewController {
    
    @objc func newItem() {
        let ac = UIAlertController(title: "Add new item", message: "Item name", preferredStyle: .alert)
        ac.addTextField()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let item = ac?.textFields?[0].text else { return }
            self?.addItem(item)
        }
        
        ac.addAction(cancelAction)
        ac.addAction(submitAction)
        
        present(ac, animated: true)
    }
    
    func addItem(_ item: String) {
        items.insert(item, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    
    @objc func share() {
        let list = items.joined(separator: "\n")
        print(list)
        
        let vc = UIActivityViewController(activityItems: [list], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}


extension ViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath)
        cell.textLabel?.text = "\(items[indexPath.row])"
        
        return cell
    }
}

