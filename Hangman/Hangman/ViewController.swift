import UIKit

class ViewController: UIViewController {
    
    var correctWord = ""
    var triesLeft = 7 {
        didSet {
            numberOfTries.text = "\(triesLeft) tries left"
        }
    }
    
    var words: [String]!
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var numberOfTries: UILabel!
    
    var charactersFound = [Character]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "HANGMAN"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(restartGame))
        
        DispatchQueue.global().async {
            self.initiateWordListFromFile(fileName: "words1", extension: "txt")
            DispatchQueue.main.async {
                self.setLabels()
            }
        }
    }
    

    @IBAction func letterTapped(_ sender: UIButton) {
        sender.isEnabled = false
        
        let char = Character((sender.titleLabel?.text!)!)
        var isCorrect = false
        
        for (index, ch) in correctWord.enumerated() {
            if char == ch {
                charactersFound.append(char)
                labels[index].text = "\(char)"
                isCorrect = true
            }
        }
        
        triesLeft = isCorrect ? triesLeft : triesLeft - 1
        if checkifWon() {
            let ac = UIAlertController(title: "Congratulations", message: "You WON!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Restart", style: .default, handler: pickNewWord))
            
            present(ac, animated: true)
        }

        if triesLeft == 0 {
            // End of game
            let ac = UIAlertController(title: "Restart Game", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: pickNewWord))
            
            present(ac, animated: true)
        }
    }
    
    @objc func restartGame() {
        let msg = "Are you sure you want to restart?"
        let ac = UIAlertController(title: "Restart Game", message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: pickNewWord))
        
        present(ac, animated: true)
    }
    
    func initiateWordListFromFile(fileName: String, extension ext: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            if let wordsFileURL = Bundle.main.url(forResource: fileName, withExtension: ext) {
                if let fileContents = try? String(contentsOf: wordsFileURL) {
                    self.words = fileContents.components(separatedBy: "\n")
                    self.words.shuffle()
                    
                    self.correctWord = self.words[0]
                    print(self.correctWord)
                }
            }
        }
    }
    
    func pickNewWord(action: UIAlertAction) {
        for btn in buttons {
            btn.isEnabled = true
        }
                
        repeat {
            words.shuffle()
        } while correctWord == words[0] || correctWord == ""
        
        correctWord = words[0]
        setLabels()
        charactersFound.removeAll()
    }
    
    func setLabels() {
        for label in labels {
            label.text = "_"
        }
        
        for lbl in labels {
            
            if lbl.tag > correctWord.count - 1 {
                lbl.isHidden = true
            } else {
                lbl.isHidden = false
            }
        }

        triesLeft = 7
    }
    
    func checkifWon() -> Bool {
        for letter in correctWord {
            if !charactersFound.contains(letter) {
                return false
            }
        }
        return true
    }
}

