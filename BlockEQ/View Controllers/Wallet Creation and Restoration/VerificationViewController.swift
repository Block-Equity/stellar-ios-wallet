//
//  RecoveryViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-11.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit
import stellarsdk

protocol VerificationViewControllerDelegate: AnyObject {
    func validatedAccount(_ viewController: VerificationViewController, mnemonic: String)
}

class VerificationViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var progressView: UIView!
    @IBOutlet var progressViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var quicktypeView: UIView!
    @IBOutlet var questionHolderView: UIView!
    @IBOutlet var questionTitleLabel: UILabel!
    @IBOutlet var questionSubtitleLabel: UILabel!
    @IBOutlet var questionViewHeightConstraint: NSLayoutConstraint!

    weak var delegate: VerificationViewControllerDelegate?

    public enum VerificationType {
        case recovery
        case confirmation
        case questions
    }

    let defaultQuestionViewHeight: CGFloat = 88.0
    let questionTextViewHeight: CGFloat = 48.0
    let totalQuestionCount = 4
    var questionsAnswered = 0
    var progressWidth: CGFloat {
        return UIScreen.main.bounds.size.width / CGFloat(totalQuestionCount)
    }

    var defaultTextViewHeight: CGFloat = {
        if UIScreen.main.bounds.size.width == 320 {
            return 125.0
        } else {
            return 150.0
        }
    }()

    var type: VerificationType = .recovery
    var suggestions: [String] = []
    var questionWords: [String] = []
    var currentWord: String = ""
    var mnemonic: String = ""

    @IBAction func nextButtonSelected() {
        switch type {
        case .questions:
            validateAnswer()
        default:
            guard var mnemonicString = textView.text, !mnemonicString.isEmpty else {
                return
            }

            let lastCharater = mnemonicString.last
            if lastCharater == " " {
                mnemonicString = String(mnemonicString.dropLast())
            }

            textView.text = ""
            delegate?.validatedAccount(self, mnemonic: mnemonicString)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(type: VerificationType, mnemonic: String) {
        super.init(nibName: String(describing: VerificationViewController.self), bundle: nil)

        self.type = type
        self.mnemonic = mnemonic
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        textView.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        textView.text = ""
    }

    func setupView() {
        let collectionViewNib = UINib(nibName: WordSuggestionCell.cellIdentifier, bundle: nil)
        collectionView.register(collectionViewNib, forCellWithReuseIdentifier: WordSuggestionCell.cellIdentifier)

        switch type {
        case .confirmation:
            navigationItem.title = "Re-enter Your Phrase"

            questionViewHeightConstraint.constant = 0.0
            textViewHeightConstraint.constant = defaultTextViewHeight
        case .questions:
            questionViewHeightConstraint.constant = defaultQuestionViewHeight
            textViewHeightConstraint.constant = questionTextViewHeight

            setQuestion(animated: false)
        default:
            navigationItem.title = "Enter Phrase"

            questionViewHeightConstraint.constant = 0.0
            textViewHeightConstraint.constant = defaultTextViewHeight
        }

        textView.textContainerInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        textView.inputAccessoryView = quicktypeView

        progressView.backgroundColor = Colors.tertiaryDark
        textView.textColor = Colors.darkGray
        questionHolderView.backgroundColor = Colors.lightBackground
        questionTitleLabel.textColor = Colors.darkGray
        questionSubtitleLabel.textColor = Colors.darkGray
        view.backgroundColor = Colors.lightBackground
    }

    @objc func dismissView() {
        view.endEditing(true)

        dismiss(animated: true, completion: nil)
    }

    func getWords(string: String) -> [String] {
        let components = string.components(separatedBy: .whitespacesAndNewlines)

        return components.filter { !$0.isEmpty }
    }

    func clearSuggestions(reload: Bool) {
        suggestions.removeAll()

        if reload {
            collectionView.reloadData()
        }
    }

    func getAutocompleteSuggestions(userText: String) -> [String] {
        var possibleMatches: [String] = []
        let language: WordList = .english

        for item in language.englishWords {
            let myString: NSString! = item as NSString
            let substringRange: NSRange! = myString.range(of: userText)

            if substringRange.location == 0 {
                possibleMatches.append(item)
            }
        }
        return possibleMatches.enumerated().compactMap { $0.offset < 3 ? $0.element : nil }
    }

    func validateAnswer() {
        if textView.text == currentWord {
            if questionsAnswered == 4 {
                delegate?.validatedAccount(self, mnemonic: mnemonic)
            } else {
                textView.text = ""
                setQuestion(animated: true)
            }
        } else {
            textView.textColor = UIColor.red
            textView.shake()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.textView.text = ""
                self.textView.textColor = Colors.darkGray
            }
        }
    }

    func setQuestion(animated: Bool) {
        if questionWords.count == 0 {
            questionWords = mnemonic.components(separatedBy: " ")
        }

        let randomIndex = Int(arc4random_uniform(UInt32(questionWords.count)))
        currentWord = questionWords[randomIndex]

        if let indexOfWord = mnemonic.components(separatedBy: " ").index(of: currentWord) {
            questionTitleLabel.text = "What was the word \(String(describing: indexOfWord + 1))?"
            questionWords.remove(at: randomIndex)
            questionsAnswered += 1

            setProgress(animated: animated)
        }
    }

    func setProgress(animated: Bool) {
        progressViewWidthConstraint.constant += progressWidth

        navigationItem.title = "Question \(questionsAnswered) of \(totalQuestionCount)"

        if animated {
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension VerificationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        clearSuggestions(reload: false)

        let subString = (textView.text! as NSString).replacingCharacters(in: range, with: text)

        if let lastWord = getWords(string: String(subString)).last {
            suggestions.append(contentsOf: getAutocompleteSuggestions(userText: lastWord))
        }

        collectionView.reloadData()

        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        highlightWrongWords(targetString: textView.text)
    }
}

extension VerificationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suggestions.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WordSuggestionCell.cellIdentifier,
                                                      for: indexPath)
        if let wordCell = cell as? WordSuggestionCell {
            wordCell.titleLabel.text = suggestions[indexPath.row]
        }

        return cell
    }
}

extension VerificationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let suggestion = suggestions[indexPath.row]
        var words = getWords(string: textView.text)
        if words.count > 0 {
            words.removeLast()
        }
        words.append(suggestion)

        textView.text = words.joined(separator: " ")

        if type != .questions {
            textView.text.append(" ")
        }

        clearSuggestions(reload: true)

        highlightWrongWords(targetString: textView.text)
    }
}

extension VerificationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width / 3, height: collectionView.frame.size.height)
    }
}

extension VerificationViewController {
    func highlightWrongWords(targetString: String) {
        let attributedString = NSMutableAttributedString(string: targetString)
        let range = NSRange(location: 0, length: targetString.utf16.count)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.black, range: range)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16.0), range: range)

        let words = getWords(string: targetString)

        for word in words {
            let color = isReal(word: word) ? Colors.black : Colors.red
            textView.attributedText = getHighlightedAttributedString(attributedString: attributedString,
                                                                     word: word,
                                                                     in: targetString,
                                                                     highlightColor: color)
        }
    }

    func getHighlightedAttributedString(attributedString: NSMutableAttributedString,
                                        word: String,
                                        in targetString: String,
                                        highlightColor: UIColor) -> NSMutableAttributedString {
        do {
            let regex = try NSRegularExpression(pattern: word, options: .caseInsensitive)
            let range = NSRange(location: 0, length: targetString.utf16.count)
            for match in regex.matches(in: targetString, options: .withTransparentBounds, range: range) {
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                              value: highlightColor,
                                              range: match.range)
            }

            return attributedString
        } catch _ {
            return attributedString
        }
    }

    func isReal(word: String) -> Bool {
        let language: WordList = .english
        return language.englishWords.contains(word)
    }
}
