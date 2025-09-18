import UIKit

/// Manages the floating button for quick access to ChuckerIOS
public class FloatingButtonManager {
    
    private var floatingButton: FloatingButton?
    private var badgeLabel: UILabel?
    
    public init() {
        setupFloatingButton()
    }
    
    private func setupFloatingButton() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        floatingButton = FloatingButton()
        floatingButton?.delegate = self
        
        window.addSubview(floatingButton!)
        
        // Position the button
        floatingButton?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            floatingButton!.trailingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            floatingButton!.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            floatingButton!.widthAnchor.constraint(equalToConstant: 56),
            floatingButton!.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        show()
    }
    
    public func show() {
        floatingButton?.isHidden = false
    }
    
    public func hide() {
        floatingButton?.isHidden = true
    }
    
    public func updateBadge(count: Int) {
        floatingButton?.updateBadge(count: count)
    }
}

// MARK: - FloatingButtonDelegate

extension FloatingButtonManager: FloatingButtonDelegate {
    func floatingButtonTapped() {
        ChuckerIOS.shared.show()
    }
}

// MARK: - FloatingButton

protocol FloatingButtonDelegate: AnyObject {
    func floatingButtonTapped()
}

class FloatingButton: UIView {
    
    weak var delegate: FloatingButtonDelegate?
    
    private let button = UIButton(type: .system)
    private let badgeView = UIView()
    private let badgeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Configure main button
        button.setTitle("🌐", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        // Configure badge
        badgeView.backgroundColor = UIColor.systemRed
        badgeView.layer.cornerRadius = 10
        badgeView.isHidden = true
        
        badgeLabel.textColor = .white
        badgeLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        badgeLabel.textAlignment = .center
        
        // Add subviews
        addSubview(button)
        addSubview(badgeView)
        badgeView.addSubview(badgeLabel)
        
        // Setup constraints
        button.translatesAutoresizingMaskIntoConstraints = false
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            badgeView.topAnchor.constraint(equalTo: topAnchor, constant: -4),
            badgeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 4),
            badgeView.widthAnchor.constraint(equalToConstant: 20),
            badgeView.heightAnchor.constraint(equalToConstant: 20),
            
            badgeLabel.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
            badgeLabel.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor)
        ])
    }
    
    @objc private func buttonTapped() {
        delegate?.floatingButtonTapped()
    }
    
    func updateBadge(count: Int) {
        if count > 0 {
            badgeLabel.text = "\(count)"
            badgeView.isHidden = false
        } else {
            badgeView.isHidden = true
        }
    }
}
