import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var interests = [Interests]()
    var newLabel = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Interests"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewInterest))
        
        tableView.rowHeight = 120
        
        let defaults = UserDefaults.standard
        load(defaults)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interests.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            
            let path = getDocumentsDirectory().appendingPathComponent(interests[indexPath.row].image)
            vc.imagePath = path
            
            vc.text = interests[indexPath.row].label
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InterestsCell", for: indexPath) as? InterestsCell else {
            fatalError("Oink")
        }
        
        let interest = interests[indexPath.row]
        cell.label.text = interest.label
        
        let path = getDocumentsDirectory().appendingPathComponent(interest.image)
        cell.cellImageView.image = UIImage(contentsOfFile: path.path)
        
        return cell
    }
    
    
    @objc func addNewInterest() {
        let ac = UIAlertController(title: "New Interest", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let imagePickerAC = UIAlertAction(title: "Pick Image", style: .default) { _ in
            let text = ac.textFields?.first?.text ?? ""
            self.presentImagePicker(withLabel: text)
        }
        
        ac.addAction(imagePickerAC)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
    }
    
    

    // MARK: - Image Picker
    func presentImagePicker(withLabel label: String) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: {
            self.newLabel = label
        })
    }
    
    // Handle image selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            // Display selected image
            let imageName = UUID().uuidString
            let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
            
            // Saving image to disk
            if let jpegData = selectedImage.jpegData(compressionQuality: 0.8) {
                try? jpegData.write(to: imagePath)
            }
            
            let newInterest = Interests(label: newLabel, image: imageName)
            interests.append(newInterest)
            save()
            tableView.reloadData()
        }
        
        dismiss(animated: true) {
            self.newLabel = ""
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) {
            self.newLabel = ""
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func save() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: interests, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "interest")
        }
    }
    
    func load(_ defaults: UserDefaults) {
        if let savedInterests = defaults.object(forKey: "interest") as? Data {
            do {
                if let decodedInterests = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, Interests.self], from: savedInterests) as? [Interests] {
                    interests = decodedInterests
                }
            } catch {
                print("Failed to unarchive people: \(error)")
            }
        }
    }
    
}

