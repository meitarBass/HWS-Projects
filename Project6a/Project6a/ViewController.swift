import UIKit

class ViewController: UIViewController {

    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    
    var totalQuestionsSoFar = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(restartTapped))
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
                
        askQuestion(action: nil)
    }
    
    func askQuestion(action: UIAlertAction!) {
        totalQuestionsSoFar += 1
        
        countries.shuffle()
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        correctAnswer = Int.random(in: 0...2)
        
        title = "\(countries[correctAnswer].uppercased())"
        if score > 0 {
            title! +=  " - Your score is \(score)"
        }
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        } else {
            title = "Wrong! That's the flag of \(countries[sender.tag].capitalized)"
            score -= 1
        }
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        if totalQuestionsSoFar == 10 {
            restart(ac)
        } else {
            ac.title = "Continue"
            ac.message = "Your score is \(score)"
        }
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        present(ac, animated: true)
    }
    
    @objc func restartTapped(_ ac: UIAlertController) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        restart(ac)
        ac.message = "Game restarted"
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: askQuestion))
        present(ac, animated: true)
    }
    
    func restart(_ ac: UIAlertController) {
        ac.title = "Game Over"
        ac.message = "Total score is \(score) out of 10"
        score = 0
        totalQuestionsSoFar = 0
    }
    
}

