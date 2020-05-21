//
//  KeyboardBehaviorHandler.swift
//  Energosbyt
//
//  Created by Александр Смородов on 17.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import UIKit

class KeyboardBehaviorHandler {
    
    private weak var scrollView: UIScrollView!
    
    private var bottomOffset: CGFloat!
    
    var needHideByTap: Bool
    
    private var isKeyboardShow: Bool = false
    
    private var scrollViewInsets: UIEdgeInsets!
    
    var willShowHide:((_ show: Bool, _ height: CGFloat, _ duration: Double) -> Void)?
    
    init(scrollView: UIScrollView, bottomOffset: CGFloat = 0.0, needHideByTap: Bool = true) {
        self.scrollView = scrollView
        self.bottomOffset = bottomOffset
        self.needHideByTap = needHideByTap
        
        self.scrollView.keyboardDismissMode = .interactive
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Keyboard
    
    lazy var m_ViewTap: UITapGestureRecognizer = {
        return UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard))
    }()
    
    @objc public func hideKeyboard() {
        //TODO: не срабатывает если scrollView лежит в отдельном контейнере и этот метод не дотягивается до самой главной view у view controller (решение — использовать needHideByTap = false и hideKeyboard через тап по view в VC)
        scrollView.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification : Notification) {
        
        
        isKeyboardShow = true
        
        let info: Dictionary = notification.userInfo ?? [:]
        let keyboardSize: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? CGRect.zero
        let duration: NSNumber = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber) ?? NSNumber(value: 0.0)
        
        if needHideByTap {
            scrollView.addGestureRecognizer(m_ViewTap)
        }
        
        if scrollViewInsets == nil {
            scrollViewInsets = scrollView.contentInset
        }
        
        willShowHide?(true, keyboardSize.height, duration.doubleValue)
        
//        let bottomSpaceScrollView = UIScreen.main.bounds.height - scrollView.frame.maxY
        let bottomSpaceScrollView: CGFloat = 0
        var bottomOffsetForKeyboard = keyboardSize.height - bottomSpaceScrollView
        if bottomOffsetForKeyboard < 0  {
            bottomOffsetForKeyboard = 0
        }
        
        let contentInsets = UIEdgeInsets(top: scrollViewInsets.top, left: scrollViewInsets.left, bottom: scrollViewInsets.bottom + bottomOffsetForKeyboard - bottomOffset, right: scrollViewInsets.right)
        
        UIView.animate(withDuration: duration.doubleValue) {
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    @objc func keyboardWillHide(notification : Notification) {
        
        if !isKeyboardShow {
            return
        }
        
        isKeyboardShow = false
        
        if needHideByTap {
            scrollView.removeGestureRecognizer(m_ViewTap)
        }
        
        let info: Dictionary = notification.userInfo ?? [:]
        let duration: NSNumber = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber) ?? NSNumber(value: 0.0)
        
        
        if let willShowHide = willShowHide {
            willShowHide(false, 0.0, duration.doubleValue)
        }
        
        UIView.animate(withDuration: duration.doubleValue) {
            self.scrollView.contentInset = self.scrollViewInsets
            self.scrollView.scrollIndicatorInsets = self.scrollViewInsets
        }
    }
    
}
