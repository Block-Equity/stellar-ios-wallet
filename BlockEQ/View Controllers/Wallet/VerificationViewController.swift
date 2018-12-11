//
//  RecoveryViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-11.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub
import stellarsdk

protocol VerificationViewControllerDelegate: AnyObject {
    func validatedAccount(_ viewController: VerificationViewController, secret: StellarSeed)
    func validatedAccount(_ viewController: VerificationViewController,
                          mnemonic: StellarRecoveryMnemonic,
                          passphrase: StellarMnemonicPassphrase?)
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
    @IBOutlet weak var advancedSecurityButton: UIButton!

    weak var delegate: VerificationViewControllerDelegate?

    public enum VerificationType {
        case recovery
        case confirmation
    }

    let defaultQuestionViewHeight: CGFloat = 88.0
    let questionTextViewHeight: CGFloat = 48.0
    let totalQuestionCount = 4
    var questionsAnswered = 0

    var temporaryPassphrase: StellarMnemonicPassphrase?
    var mnemonicPassphrase: StellarMnemonicPassphrase?

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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(type: VerificationType, mnemonic: StellarRecoveryMnemonic?) {
        super.init(nibName: String(describing: VerificationViewController.self), bundle: nil)
        self.type = type
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
        mnemonicPassphrase = nil

        setupView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        textView.text = ""
        mnemonicPassphrase = nil
    }

    func setupView() {
        let collectionViewNib = UINib(nibName: WordSuggestionCell.cellIdentifier, bundle: nil)
        collectionView.register(collectionViewNib, forCellWithReuseIdentifier: WordSuggestionCell.cellIdentifier)

        switch type {
        case .confirmation:
            navigationItem.title = "REENTER_PHRASE".localized()

            questionViewHeightConstraint.constant = 0.0
            textViewHeightConstraint.constant = defaultTextViewHeight
        case .recovery:
            navigationItem.title = "RECOVER_WALLET".localized()

            questionViewHeightConstraint.constant = 0.0
            textViewHeightConstraint.constant = defaultTextViewHeight
        }

        textView.textContainerInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        textView.inputAccessoryView = quicktypeView

        progressView.backgroundColor = Colors.tertiaryDark
        textView.textColor = Colors.darkGray
        textView.textContentType = .password
        questionHolderView.backgroundColor = Colors.lightBackground
        questionTitleLabel.textColor = Colors.darkGray
        questionSubtitleLabel.textColor = Colors.darkGray
        view.backgroundColor = Colors.lightBackground

        styleAdvancedSecurity()
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

    func displayInvalidAnswer() {
        textView.textColor = UIColor.red
        textView.shake()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.textViewDidChange(self.textView)
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

// MARK: - IBActions / Actions
extension VerificationViewController {
    @IBAction func nextButtonSelected() {
        switch type {
        default:
            if let recoveryMnemonic = StellarRecoveryMnemonic(textView.text) {
                textView.text = ""
                delegate?.validatedAccount(self, mnemonic: recoveryMnemonic, passphrase: mnemonicPassphrase)
            } else if let recoverySeed = StellarSeed(textView.text) {
                textView.text = ""
                delegate?.validatedAccount(self, secret: recoverySeed)
            } else {
                displayInvalidAnswer()
            }
        }
    }

    @IBAction func advancedSecuritySelected(_ sender: Any) {
        self.clearPassphrase()
        self.passphrasePrompt(confirm: false, completion: self.setPassphrase)
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
        guard textView.text.count > 0 else { return }

        if textView.text.contains(" ") {
            highlightWrongWords(in: textView.text)
        } else {
            highlightIncorrectSeed(in: textView.text)
        }
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
        textView.text.append(" ")

        clearSuggestions(reload: true)

        highlightWrongWords(in: textView.text)
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
    func highlightWrongWords(in string: String) {
        let attributedString = NSMutableAttributedString(string: string)
        let range = NSRange(location: 0, length: string.utf16.count)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.darkGray, range: range)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16.0), range: range)

        let words = getWords(string: string)

        for word in words {
            let color = isReal(word: word) ? Colors.darkGray : Colors.red
            textView.attributedText = getHighlightedAttributedString(attributedString: attributedString,
                                                                     word: word,
                                                                     in: string,
                                                                     highlightColor: color)
        }
    }

    func highlightIncorrectSeed(in string: String) {
        let attributedString = NSMutableAttributedString(string: string)
        let range = NSRange(location: 0, length: string.utf16.count)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.darkGray, range: range)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16.0), range: range)

        if !(string.hasPrefix("S") || string.hasPrefix("s")) {
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                          value: Colors.red,
                                          range: NSRange(location: 0, length: 1))
        }

        for character in string.enumerated() {
            let chRange = NSRange(location: character.offset, length: 1)
            let object = Unicode.Scalar(String(character.element))!
            if CharacterSet.base32Alphabet.inverted.contains(object) {
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.red, range: chRange)
            }

            if character.offset > 55 {
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.red, range: chRange)
            }
        }

        textView.attributedText = attributedString
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
